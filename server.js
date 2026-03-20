#!/usr/bin/env node
/**
 * AAA Board API Server
 * Stellt Nuggets-Daten als JSON API für das Board-Visualizer bereit
 */

const http = require('http');
const { execSync } = require('child_process');

const PORT = process.env.PORT || 3000;

// CORS Headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
  'Content-Type': 'application/json'
};

// Helper: Nuggets CLI ausführen
function runNuggets(args) {
  try {
    const output = execSync(`nuggets ${args}`, { encoding: 'utf-8' });
    return output.trim();
  } catch (e) {
    console.error(`Error running nuggets ${args}:`, e.message);
    return '';
  }
}

// Helper: Board parsen
function parseBoard(output) {
  const board = { todo: [], inProgress: [], review: [], done: [] };
  
  const todoMatch = output.match(/TODO:\s*(.+)/);
  const inProgressMatch = output.match(/IN_PROGRESS:\s*(.+)/);
  const reviewMatch = output.match(/REVIEW:\s*(.+)/);
  const doneMatch = output.match(/DONE:\s*(.+)/);
  
  if (todoMatch && todoMatch[1] && todoMatch[1].trim() !== '—') {
    board.todo = todoMatch[1].split(',').map(t => t.trim()).filter(t => t);
  }
  if (inProgressMatch && inProgressMatch[1] && inProgressMatch[1].trim() !== '—') {
    board.inProgress = inProgressMatch[1].split(',').map(t => t.trim()).filter(t => t);
  }
  if (reviewMatch && reviewMatch[1] && reviewMatch[1].trim() !== '—') {
    board.review = reviewMatch[1].split(',').map(t => t.trim()).filter(t => t);
  }
  if (doneMatch && doneMatch[1] && doneMatch[1].trim() !== '—') {
    board.done = doneMatch[1].split(',').map(t => t.trim()).filter(t => t);
  }
  
  return board;
}

// Helper: Tasks parsen
function parseTasks(output) {
  const tasks = {};
  const lines = output.split('\n').filter(l => l.includes(':'));
  
  for (const line of lines) {
    const match = line.match(/^\s*(TASK-\d+):\s*(.+)$/);
    if (match) {
      const [, id, desc] = match;
      const [description, priority, estimate] = desc.split('|').map(s => s.trim());
      tasks[id] = {
        id,
        desc: description,
        priority: priority ? priority.replace('priority:', '') : 'medium',
        estimate: estimate ? estimate.replace('estimate:', '') : null
      };
    }
  }
  
  return tasks;
}

// Helper: MetaClaw Decisions parsen
function parseDecisions(output) {
  const decisions = [];
  const lines = output.split('\n').filter(l => l.includes(':'));
  
  for (const line of lines) {
    const match = line.match(/^\s*(TASK-[\w-]+):\s*(.+)$/);
    if (match) {
      const [, id, text] = match;
      decisions.push({ id, text });
    }
  }
  
  return decisions;
}

// Request Handler
const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://localhost:${PORT}`);
  
  // CORS Preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204, corsHeaders);
    res.end();
    return;
  }
  
  // Nur GET Requests
  if (req.method !== 'GET') {
    res.writeHead(405, corsHeaders);
    res.end(JSON.stringify({ error: 'Method not allowed' }));
    return;
  }
  
  console.log(`${new Date().toISOString()} - ${req.method} ${url.pathname}`);
  
  // Routes
  if (url.pathname === '/api/board') {
    const boardOutput = runNuggets('facts board');
    const tasksOutput = runNuggets('facts sprint-tasks');
    
    const board = parseBoard(boardOutput);
    const tasks = parseTasks(tasksOutput);
    
    // Tasks mit Details anreichern
    const enrichedBoard = {
      todo: board.todo.map(id => tasks[id] || { id, desc: 'Unknown', priority: 'medium' }),
      inProgress: board.inProgress.map(id => tasks[id] || { id, desc: 'Unknown', priority: 'medium' }),
      review: board.review.map(id => tasks[id] || { id, desc: 'Unknown', priority: 'medium' }),
      done: board.done.map(id => tasks[id] || { id, desc: 'Unknown', priority: 'medium' })
    };
    
    res.writeHead(200, corsHeaders);
    res.end(JSON.stringify(enrichedBoard, null, 2));
    
  } else if (url.pathname === '/api/tasks') {
    const tasksOutput = runNuggets('facts sprint-tasks');
    const tasks = parseTasks(tasksOutput);
    
    res.writeHead(200, corsHeaders);
    res.end(JSON.stringify(tasks, null, 2));
    
  } else if (url.pathname === '/api/decisions') {
    const decisionsOutput = runNuggets('facts metaclaw-decisions');
    const decisions = parseDecisions(decisionsOutput);
    
    res.writeHead(200, corsHeaders);
    res.end(JSON.stringify(decisions, null, 2));
    
  } else if (url.pathname === '/api/health') {
    res.writeHead(200, corsHeaders);
    res.end(JSON.stringify({ status: 'ok', timestamp: new Date().toISOString() }));
    
  } else if (url.pathname === '/' || url.pathname === '') {
    // Serve board.html
    const fs = require('fs');
    const path = require('path');
    const boardPath = path.join(__dirname, 'board.html');
    
    fs.readFile(boardPath, 'utf8', (err, data) => {
      if (err) {
        res.writeHead(404, corsHeaders);
        res.end('board.html not found');
        return;
      }
      res.writeHead(200, { ...corsHeaders, 'Content-Type': 'text/html' });
      res.end(data);
    });
    
  } else {
    res.writeHead(404, corsHeaders);
    res.end(JSON.stringify({ error: 'Not found' }));
  }
});

server.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════════════════════════╗
║         🚀 AAA Board API Server                           ║
╠═══════════════════════════════════════════════════════════╣
║  Running on: http://localhost:${PORT}                      ║
║                                                           ║
║  Endpoints:                                               ║
║  GET /api/board      - Full board with task details       ║
║  GET /api/tasks      - All tasks                          ║
║  GET /api/decisions  - MetaClaw decisions                 ║
║  GET /api/health     - Health check                       ║
║  GET /               - Board Visualizer (HTML)            ║
║                                                           ║
║  Press Ctrl+C to stop                                     ║
╚═══════════════════════════════════════════════════════════╝
  `);
});
