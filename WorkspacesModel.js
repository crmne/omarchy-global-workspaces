function numericId(value) {
  var text = String(value)
  if (!/^[1-9][0-9]*$/.test(text)) return null
  var id = Number(text)
  return Number.isSafeInteger(id) ? id : null
}

function workspaceIds(workspaces, rules) {
  var ids = [1, 2, 3, 4, 5]
  function add(value) {
    var id = numericId(value)
    if (id !== null && ids.indexOf(id) === -1) ids.push(id)
  }
  for (var i = 0; i < workspaces.length; i++) add(workspaces[i].id)
  for (var j = 0; j < rules.length; j++) add(rules[j].workspaceString)
  return ids.sort(function(left, right) { return left - right })
}

function label(id) { return id === 10 ? "0" : String(id) }

function focusExpression(id) {
  var value = numericId(id)
  return value === null ? "" : 'hl.dsp.focus({ workspace = "' + value + '" })'
}

if (typeof module !== "undefined") module.exports = { workspaceIds, label, focusExpression }
