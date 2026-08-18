#!/usr/bin/env node

import { readFile } from "node:fs/promises"
import { resolve } from "node:path"

const graphPath = process.argv[2]
if (!graphPath) {
  console.error("Usage: node scripts/validate-data-graph.mjs <graph.data-graph.json>")
  process.exit(2)
}

const fail = (message) => {
  console.error(`Invalid data graph: ${message}`)
  process.exit(1)
}
const record = (value) => value !== null && typeof value === "object" && !Array.isArray(value)
const point = (value) => record(value) && Number.isFinite(value.x) && Number.isFinite(value.y)
const nodeKinds = new Set(["input", "source", "value", "transform", "branch", "output", "reference", "note"])
const edgeKinds = new Set(["data", "control", "reference"])

const absolutePath = resolve(graphPath)
let graph
try {
  graph = JSON.parse(await readFile(absolutePath, "utf8"))
} catch (error) {
  fail(`could not read JSON (${error instanceof Error ? error.message : String(error)})`)
}

if (!record(graph) || graph.schema !== "uidesign.data-graph/v1") fail("schema must be uidesign.data-graph/v1")
if (!graph.id || typeof graph.id !== "string") fail("id must be a non-empty string")
if (!graph.title || typeof graph.title !== "string") fail("title must be a non-empty string")
if (!record(graph.groupsById) || !record(graph.nodesById) || !record(graph.edgesById)) fail("groupsById, nodesById, and edgesById are required")
if (!record(graph.layout) || !record(graph.layout.groupsById) || !record(graph.layout.nodesById)) fail("layout groupsById and nodesById are required")

for (const [groupId, group] of Object.entries(graph.groupsById)) {
  const layout = graph.layout.groupsById[groupId]
  if (!record(group) || group.id !== groupId || typeof group.label !== "string") fail(`group ${groupId} is malformed`)
  if (!record(layout) || !point(layout.position) || !Number.isFinite(layout.width) || !Number.isFinite(layout.height)) fail(`group ${groupId} needs a valid layout`)
}

for (const [nodeId, node] of Object.entries(graph.nodesById)) {
  const layout = graph.layout.nodesById[nodeId]
  if (!record(node) || node.id !== nodeId || typeof node.label !== "string" || !nodeKinds.has(node.kind) || !Array.isArray(node.ports)) fail(`node ${nodeId} is malformed`)
  if (node.groupId && !graph.groupsById[node.groupId]) fail(`node ${nodeId} references missing group ${node.groupId}`)
  if (!record(layout) || !point(layout.position)) fail(`node ${nodeId} needs a valid layout`)
  const portIds = new Set()
  for (const port of node.ports) {
    if (!record(port) || !port.id || typeof port.id !== "string" || portIds.has(port.id)) fail(`node ${nodeId} has an invalid or duplicate port`)
    if (typeof port.label !== "string" || !["input", "output"].includes(port.direction)) fail(`node ${nodeId} port ${port.id} is malformed`)
    if (port.dataType !== undefined && typeof port.dataType !== "string") fail(`node ${nodeId} port ${port.id} has an invalid dataType`)
    portIds.add(port.id)
  }
}

for (const [edgeId, edge] of Object.entries(graph.edgesById)) {
  if (!record(edge) || edge.id !== edgeId || !edgeKinds.has(edge.kind) || !record(edge.source) || !record(edge.target)) fail(`edge ${edgeId} is malformed`)
  const source = graph.nodesById[edge.source.nodeId]
  const target = graph.nodesById[edge.target.nodeId]
  if (!source || !target) fail(`edge ${edgeId} references a missing node`)
  const sourcePort = source.ports.find((port) => port.id === edge.source.portId)
  const targetPort = target.ports.find((port) => port.id === edge.target.portId)
  if (!sourcePort || sourcePort.direction !== "output") fail(`edge ${edgeId} source must be an output port`)
  if (!targetPort || targetPort.direction !== "input") fail(`edge ${edgeId} target must be an input port`)
  if (sourcePort.dataType && targetPort.dataType && sourcePort.dataType !== targetPort.dataType) fail(`edge ${edgeId} connects incompatible data types`)
}

console.log(`Valid data graph: ${absolutePath}`)
