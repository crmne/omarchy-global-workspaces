const assert = require('node:assert/strict')
const { test } = require('node:test')
const model = require('../WorkspacesModel.js')

test('shows configured empty workspaces and existing workspaces from every monitor', () => {
  assert.deepEqual(model.workspaceIds([{ id: 14 }, { id: 2 }, { id: 7 }], [{ workspaceString: '6' }, { workspaceString: '12' }]), [1, 2, 3, 4, 5, 6, 7, 12, 14])
})
test('does not turn names, selectors or special workspaces into numbered destinations', () => {
  assert.deepEqual(model.workspaceIds([{ id: -99 }, { id: null }], [{ workspaceString: 'special:scratchpad' }, { workspaceString: 'name:6' }, { workspaceString: 'r[1-10]' }, { workspaceString: '6; command' }]), [1, 2, 3, 4, 5])
})
test('deduplicates and sorts numbers rather than sorting labels', () => {
  assert.deepEqual(model.workspaceIds([{ id: 100 }, { id: 12 }, { id: 6 }], [{ workspaceString: '6' }, { workspaceString: '12' }]), [1, 2, 3, 4, 5, 6, 12, 100])
})
test('labels and clicks preserve global IDs above ten', () => {
  assert.equal(model.label(10), '0')
  assert.equal(model.label(12), '12')
  assert.equal(model.focusExpression(12), 'hl.dsp.focus({ workspace = "12" })')
  assert.equal(model.focusExpression('2"; unsafe'), '')
})
