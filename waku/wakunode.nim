import
  confutils, config, chronos, json_rpc/rpcserver,
  chronicles/topics_registry, # TODO: What? Need this for setLoglevel, weird.
  eth/[keys, p2p, async_utils],
  eth/p2p/[discovery, enode, peer_pool, bootnodes, whispernodes],
  eth/p2p/rlpx_protocols/[whisper_protocol, waku_protocol, waku_bridge],
  ../nimbus/rpc/waku

proc setBootNodes(nodes: openArray[string]): seq[ENode] =
  var bootnode: ENode
  result = newSeqOfCap[ENode](nodes.len)
  for nodeId in nodes:
    # For now we can just do assert as we only pass our own const arrays.
    doAssert(initENode(nodeId, bootnode) == ENodeStatus.Success)
    result.add(bootnode)

proc connectToNodes(node: EthereumNode, nodes: openArray[string]) =
  for nodeId in nodes:
    var whisperENode: ENode
    # For now we can just do assert as we only pass our own const arrays.
    doAssert(initENode(nodeId, whisperENode) == ENodeStatus.Success)

    traceAsyncErrors node.peerPool.connectToNode(newNode(whisperENode))

proc run(config: WakuNodeConf) =
  if config.logLevel != LogLevel.NONE:
    setLogLevel(config.logLevel)

  var address: Address
  # TODO: make configurable
  address.ip = parseIpAddress("0.0.0.0")
  address.tcpPort = Port(config.tcpPort + config.portsShift)
  address.udpPort = Port(config.udpPort + config.portsShift)

  # Set-up node
  var node = newEthereumNode(config.nodekey, address, 1, nil,
    addAllCapabilities = false)
  if not config.bootnodeOnly:
    node.addCapability Waku # Always enable Waku protocol
    let wakuConfig = WakuConfig(powRequirement: config.wakuPow,
                                bloom: fullBloom(),
                                isLightNode: false,
                                maxMsgSize: waku_protocol.defaultMaxMsgSize,
                                wakuMode: config.wakuMode,
                                topics: @[])
    node.configureWaku(wakuConfig)
    if config.whisper or config.whisperBridge:
      node.addCapability Whisper
      node.protocolState(Whisper).config.powRequirement = 0.002
    if config.whisperBridge:
      node.shareMessageQueue()

  # TODO: Status fleet bootnodes are discv5? That will not work.
  let bootnodes = if config.bootnodes.len > 0: setBootNodes(config.bootnodes)
                  elif config.fleet == beta: setBootNodes(StatusBootNodes)
                  elif config.fleet == staging: setBootNodes(StatusBootNodesStaging)
                  else: @[]

  traceAsyncErrors node.connectToNetwork(bootnodes, not config.noListen,
    config.discovery)

  if not config.bootnodeOnly:
    # Optionally direct connect with a set of nodes
    if config.staticnodes.len > 0: connectToNodes(node, config.staticnodes)
    elif config.fleet == beta: connectToNodes(node, WhisperNodes)
    elif config.fleet == staging: connectToNodes(node, WhisperNodesStaging)

  if config.rpc:
    let ta = initTAddress(config.rpcAddress,
      Port(config.rpcPort + config.portsShift))
    var rpcServer = newRpcHttpServer([ta])
    let keys = newWakuKeys()
    setupWakuRPC(node, keys, rpcServer)
    rpcServer.start()

  runForever()

when isMainModule:
  let conf = WakuNodeConf.load()
  run(conf)
