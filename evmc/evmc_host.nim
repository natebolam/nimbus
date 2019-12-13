import evmc

proc evmcReleaseResultImpl(result: var evmc_result) {.cdecl.} =
  discard
  
proc evmcGetTxContextImpl(context: evmc_host_context): evmc_tx_context {.cdecl.} =
  discard

proc evmcGetBlockHashImpl(context: evmc_host_context, number: int64): evmc_bytes32 {.cdecl.} =
  discard

proc evmcAccountExistsImpl(context: evmc_host_context, address: evmc_address): bool {.cdecl.} =
  discard

proc evmcGetStorageImpl(context: evmc_host_context, address: evmc_address, key: evmc_bytes32): evmc_bytes32 {.cdecl.} =
  discard

proc evmcSetStorageImpl(context: evmc_host_context, address: evmc_address,
                        key, value: evmc_bytes32): evmc_storage_status {.cdecl.} =
  discard

proc evmcGetBalanceImpl(context: evmc_host_context, address: evmc_address): evmc_uint256be {.cdecl.} =
  discard

proc evmcGetCodeSizeImpl(context: evmc_host_context, address: evmc_address): uint {.cdecl.} =
  discard

proc evmcGetCodeHashImpl(context: evmc_host_context, address: evmc_address): evmc_bytes32 {.cdecl.} =
  discard

proc evmcCopyCodeImpl(context: evmc_host_context, address: evmc_address,
                            code_offset: uint, buffer_data: ptr byte,
                            buffer_size: uint): uint {.cdecl.} =
  discard

proc evmcSelfdestructImpl(context: evmc_host_context, address, beneficiary: evmc_address) {.cdecl.} =
  discard

proc evmcEmitLogImpl(context: evmc_host_context, address: evmc_address,
                           data: ptr byte, data_size: uint,
                           topics: ptr evmc_bytes32, topics_count: uint) {.cdecl.} =
  discard

proc evmcCallImpl(context: evmc_host_context, msg: evmc_message): evmc_result {.cdecl.} =
  discard

proc evmcSetOptionImpl(vm: var evmc_vm, name, value: cstring): evmc_set_option_result {.cdecl.} =
  discard

proc evmcExecuteImpl(vm: var evmc_vm, host: evmc_host_interface,
                          context: evmc_host_context, rev: evmc_revision,
                          msg: evmc_message, code: ptr byte, code_size: uint): evmc_result {.cdecl.} =
  discard

proc evmcGetCapabilitiesImpl(vm: evmc_vm): evmc_capabilities {.cdecl.} =
  result.incl(EVMC_CAPABILITY_EVM1)
  result.incl(EVMC_CAPABILITY_PRECOMPILES)

proc evmcDestroyImpl(vm: var evmc_vm) {.cdecl.} =
  discard

proc nimbus_init_host_interface(host: var evmc_host_interface) {.exportc, cdecl.} =
  host.account_exists = evmcAccountExistsImpl
  host.get_storage = evmcGetStorageImpl
  host.set_storage = evmcSetStorageImpl
  host.get_balance = evmcGetBalanceImpl
  host.get_code_size = evmcGetCodeSizeImpl
  host.get_code_hash = evmcGetCodeHashImpl
  host.copy_code = evmcCopyCodeImpl
  host.selfdestruct = evmcSelfdestructImpl
  host.call = evmcCallImpl
  host.get_tx_context = evmcGetTxContextImpl
  host.get_block_hash = evmcGetBlockHashImpl
  host.emit_log = evmcEmitLogImpl

const
  # TODO: hmm?
  EVMC_HOST_NAME = "Nimbus EVM"
  EVMC_VM_VERSION = "1.0.0"

proc nimbus_init_evmc_vm(vm: var evmc_vm) {.exportc, cdecl.} =
  vm.abi_version = EVMC_ABI_VERSION
  vm.name = EVMC_HOST_NAME
  vm.version = EVMC_VM_VERSION
  vm.destroy = evmcDestroyImpl
  vm.execute = evmcExecuteImpl
  vm.get_capabilities = evmcGetCapabilitiesImpl
  vm.set_option = evmcSetOptionImpl

proc nimbus_get_host_context(): evmc_host_context {.exportc, cdecl.} =
  discard
