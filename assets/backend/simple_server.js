// 🚀 QUICK WEBSOCKET SERVER - backend/simple_server.js
// Create this file if the main server has issues

const express = require('express');
const WebSocket = require('ws');
const http = require('http');

const app = express();
const server = http.createServer(app);

// 🔌 WebSocket Server Setup
const wss = new WebSocket.Server({ server, path: '/ws' });

console.log('🚀 Starting NeuronVault WebSocket Server...');

// 📡 Handle WebSocket connections
wss.on('connection', (ws, req) => {
  console.log('✅ New WebSocket connection established');

  // 📱 Send welcome message
  ws.send(JSON.stringify({
    type: 'status',
    content: 'Connected to NeuronVault server',
    timestamp: new Date().toISOString()
  }));

  // 📥 Handle incoming messages
  ws.on('message', (data) => {
    try {
      const message = JSON.parse(data.toString());
      console.log(`📥 Received: ${message.type} - "${message.content}"`);

      if (message.type === 'user_message') {
        handleUserMessage(ws, message);
      }
    } catch (error) {
      console.error('❌ Message parsing error:', error);
      ws.send(JSON.stringify({
        type: 'error',
        content: 'Invalid message format',
        timestamp: new Date().toISOString()
      }));
    }
  });

  ws.on('close', () => {
    console.log('🔄 WebSocket connection closed');
  });

  ws.on('error', (error) => {
    console.error('🚨 WebSocket error:', error);
  });
});

// 🤖 Handle user messages with mock AI response
function handleUserMessage(ws, message) {
  const { content, strategy } = message;

  console.log(`🧠 Processing message with strategy: ${strategy}`);

  // 📤 Send processing status
  ws.send(JSON.stringify({
    type: 'status',
    content: 'Processing your request...',
    data: { strategy },
    timestamp: new Date().toISOString()
  }));

  // 🔄 Simulate streaming response
  setTimeout(() => {
    ws.send(JSON.stringify({
      type: 'partial_response',
      content: `Hello! I received your message: "${content}". `,
      data: { strategy },
      timestamp: new Date().toISOString()
    }));

    setTimeout(() => {
      ws.send(JSON.stringify({
        type: 'partial_response',
        content: 'NeuronVault WebSocket connection is working perfectly! ',
        data: { strategy },
        timestamp: new Date().toISOString()
      }));

      setTimeout(() => {
        ws.send(JSON.stringify({
          type: 'final_response',
          content: '🎉 Integration successful!',
          data: {
            strategy,
            models_used: ['test'],
            processing_time_ms: 1500
          },
          timestamp: new Date().toISOString()
        }));
      }, 800);
    }, 700);
  }, 500);
}

// 🚀 Start server
const PORT = 3001;
server.listen(PORT, () => {
  console.log(`🚀 NeuronVault Server running on http://localhost:${PORT}`);
  console.log(`📡 WebSocket available on ws://localhost:${PORT}/ws`);
  console.log(`✅ Ready for Flutter connections!`);
});

// 🛡️ Error handling
server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    console.error(`❌ Port ${PORT} is in use. Kill the process and try again.`);
    console.log('🔧 Run: netstat -ano | findstr :3001');
  } else {
    console.error('❌ Server error:', error);
  }
});

process.on('SIGINT', () => {
  console.log('\n🛑 Shutting down server...');
  server.close(() => {
    console.log('✅ Server closed successfully');
    process.exit(0);
  });
});

module.exports = { app, server, wss };