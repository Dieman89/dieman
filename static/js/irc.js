(function () {
  "use strict";

  const IRC_SERVER = "wss://web.libera.chat/webirc/websocket/";
  const CHANNEL = "#dieman";
  const NICK_PREFIX = "dmn_";

  const statusEl = document.getElementById("chat-status");
  const statusDot = statusEl?.querySelector(".chat-status-dot");
  const messagesEl = document.getElementById("chat-messages");
  const formEl = document.getElementById("chat-form");
  const inputEl = document.getElementById("chat-input");
  const usersEl = document.getElementById("chat-users");
  const topicEl = document.getElementById("chat-topic");
  const topicMetaEl = document.getElementById("chat-topic-meta");
  const userCountEl = document.getElementById("chat-user-count");
  const nickEl = document.getElementById("chat-nick");

  if (!statusEl || !messagesEl || !formEl || !inputEl) return;

  let ws = null;
  let nickname = "";
  let isConnected = false;
  let reconnectAttempts = 0;
  const MAX_RECONNECT_ATTEMPTS = 5;
  const RECONNECT_DELAY = 3000;

  const users = new Map();
  let namesBuffer = [];

  function generateNick() {
    return NICK_PREFIX + Math.floor(10000 + Math.random() * 90000);
  }

  function setStatus(status) {
    statusDot.className = "chat-status-dot " + status;
    const connected = status === "connected";
    inputEl.disabled = !connected;
    isConnected = connected;
  }

  function updateNickDisplay() {
    if (nickEl) {
      nickEl.textContent = nickname;
    }
  }

  function escapeHtml(text) {
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
  }

  function parseNickWithMode(nickStr) {
    const modes = ["~", "&", "@", "%", "+"];
    let mode = "";
    let nick = nickStr;

    for (const m of modes) {
      if (nickStr.startsWith(m)) {
        mode = m;
        nick = nickStr.substring(1);
        break;
      }
    }

    return { nick, mode };
  }

  function getModePriority(mode) {
    const priorities = { "~": 0, "&": 1, "@": 2, "%": 3, "+": 4, "": 5 };
    return priorities[mode] ?? 5;
  }

  function renderUsers() {
    if (!usersEl) return;

    const sorted = Array.from(users.entries()).sort((a, b) => {
      const priorityDiff = getModePriority(a[1].mode) - getModePriority(b[1].mode);
      if (priorityDiff !== 0) return priorityDiff;
      return a[0].toLowerCase().localeCompare(b[0].toLowerCase());
    });

    usersEl.innerHTML = sorted
      .map(([nick, data]) => {
        const isMe = nick === nickname;
        return (
          '<div class="chat-user' + (isMe ? " chat-user-me" : "") + '">' +
          (data.mode ? '<span class="chat-user-mode">' + escapeHtml(data.mode) + "</span>" : "") +
          escapeHtml(nick) +
          "</div>"
        );
      })
      .join("");

    if (userCountEl) {
      const count = users.size;
      userCountEl.textContent = count + (count === 1 ? " user" : " users");
    }
  }

  function addUser(nickStr) {
    const { nick, mode } = parseNickWithMode(nickStr);
    users.set(nick, { mode });
  }

  function removeUser(nick) {
    users.delete(nick);
    renderUsers();
  }

  function setTopic(topic, setter, time) {
    if (topicEl) {
      topicEl.textContent = topic || "No topic set";
    }
    if (topicMetaEl && setter) {
      const date = time ? new Date(parseInt(time) * 1000) : new Date();
      const formatted = date.toLocaleDateString(undefined, {
        weekday: "short",
        day: "numeric",
        month: "short",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
      });
      topicMetaEl.textContent = "set by " + setter + " at " + formatted;
    }
  }

  function addMessage(type, nick, text) {
    const msgEl = document.createElement("div");
    msgEl.className = "chat-message chat-message-" + type;

    const time = new Date().toLocaleTimeString([], {
      hour: "2-digit",
      minute: "2-digit",
    });

    if (type === "privmsg") {
      const isMe = nick === nickname;
      const userData = users.get(nick);
      const mode = userData?.mode || "";
      msgEl.innerHTML =
        '<span class="chat-time">' + time + "</span>" +
        '<span class="chat-nick' + (isMe ? " chat-nick-me" : "") + '">' +
        (mode ? '<span class="chat-nick-mode">' + escapeHtml(mode) + "</span>" : "") +
        escapeHtml(nick) +
        "</span> " +
        '<span class="chat-text">' + escapeHtml(text) + "</span>";
    } else if (type === "action") {
      msgEl.innerHTML =
        '<span class="chat-time">' + time + "</span>" +
        '<span class="chat-action">* ' + escapeHtml(nick) + " " + escapeHtml(text) + "</span>";
    } else if (type === "system") {
      msgEl.innerHTML =
        '<span class="chat-time">' + time + "</span>" +
        '<span class="chat-system">' + escapeHtml(text) + "</span>";
    } else if (type === "event") {
      msgEl.innerHTML =
        '<span class="chat-time">' + time + "</span>" +
        '<span class="chat-event">' + escapeHtml(nick) + " " + escapeHtml(text) + "</span>";
    }

    messagesEl.appendChild(msgEl);
    messagesEl.scrollTop = messagesEl.scrollHeight;

    while (messagesEl.children.length > 200) {
      messagesEl.removeChild(messagesEl.firstChild);
    }
  }

  function sendRaw(command) {
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(command + "\r\n");
    }
  }

  function parseMessage(raw) {
    let prefix = "";
    let trailing = "";
    let params = [];

    if (raw.startsWith(":")) {
      const spaceIdx = raw.indexOf(" ");
      prefix = raw.substring(1, spaceIdx);
      raw = raw.substring(spaceIdx + 1);
    }

    const trailingIdx = raw.indexOf(" :");
    if (trailingIdx !== -1) {
      trailing = raw.substring(trailingIdx + 2);
      raw = raw.substring(0, trailingIdx);
    }

    params = raw.split(" ").filter(Boolean);
    const command = params.shift();

    if (trailing) params.push(trailing);

    return { prefix, command, params };
  }

  function getNick(prefix) {
    const bangIdx = prefix.indexOf("!");
    return bangIdx !== -1 ? prefix.substring(0, bangIdx) : prefix;
  }

  let topicSetter = "";
  let topicTime = "";

  function handleMessage(raw) {
    const msg = parseMessage(raw.trim());

    switch (msg.command) {
      case "PING":
        sendRaw("PONG :" + msg.params[0]);
        break;

      case "001":
        setStatus("connected");
        sendRaw("JOIN " + CHANNEL);
        addMessage("system", "", "Connected to Libera.Chat as " + nickname);
        break;

      case "332": // RPL_TOPIC
        setTopic(msg.params[2] || "", topicSetter, topicTime);
        break;

      case "333": // RPL_TOPICWHOTIME
        topicSetter = msg.params[2]?.split("!")[0] || "";
        topicTime = msg.params[3] || "";
        if (topicEl.textContent && topicEl.textContent !== "Connecting...") {
          setTopic(topicEl.textContent, topicSetter, topicTime);
        }
        break;

      case "353": // RPL_NAMREPLY
        const names = msg.params[3]?.split(" ") || [];
        namesBuffer.push(...names);
        break;

      case "366": // RPL_ENDOFNAMES
        users.clear();
        namesBuffer.forEach((n) => {
          if (n.trim()) addUser(n.trim());
        });
        namesBuffer = [];
        renderUsers();
        break;

      case "JOIN":
        const joinNick = getNick(msg.prefix);
        if (joinNick === nickname) {
          users.clear();
        } else {
          addUser(joinNick);
          renderUsers();
          addMessage("event", joinNick, "joined the channel");
        }
        break;

      case "PART":
        const partNick = getNick(msg.prefix);
        if (partNick !== nickname) {
          removeUser(partNick);
          addMessage("event", partNick, "left the channel");
        }
        break;

      case "QUIT":
        const quitNick = getNick(msg.prefix);
        if (users.has(quitNick)) {
          removeUser(quitNick);
          addMessage("event", quitNick, "quit");
        }
        break;

      case "NICK":
        const oldNick = getNick(msg.prefix);
        const newNick = msg.params[0];
        if (oldNick === nickname) {
          nickname = newNick;
          updateNickDisplay();
        }
        if (users.has(oldNick)) {
          const userData = users.get(oldNick);
          users.delete(oldNick);
          users.set(newNick, userData);
          renderUsers();
          addMessage("event", oldNick, "is now known as " + newNick);
        }
        break;

      case "MODE":
        if (msg.params[0] === CHANNEL) {
          sendRaw("NAMES " + CHANNEL);
        }
        break;

      case "TOPIC":
        setTopic(msg.params[1] || "", getNick(msg.prefix), Date.now() / 1000);
        addMessage("event", getNick(msg.prefix), "changed the topic");
        break;

      case "PRIVMSG":
        const target = msg.params[0];
        if (target !== CHANNEL) break;

        const text = msg.params[1] || "";
        const nick = getNick(msg.prefix);

        if (text.startsWith("\x01ACTION ") && text.endsWith("\x01")) {
          const action = text.substring(8, text.length - 1);
          addMessage("action", nick, action);
        } else {
          addMessage("privmsg", nick, text);
        }
        break;

      case "433":
        nickname = generateNick();
        sendRaw("NICK " + nickname);
        updateNickDisplay();
        break;

      case "474":
      case "475":
        addMessage("system", "", "Cannot join channel: " + (msg.params[2] || "error"));
        break;
    }
  }

  function connect() {
    if (ws) {
      ws.close();
    }

    users.clear();
    renderUsers();
    setStatus("connecting");
    setTopic("Connecting...", "", "");
    nickname = generateNick();
    updateNickDisplay();

    try {
      ws = new WebSocket(IRC_SERVER);

      ws.onopen = function () {
        reconnectAttempts = 0;
        sendRaw("CAP END");
        sendRaw("NICK " + nickname);
        sendRaw("USER dmn 0 * :dieman.dev visitor");
      };

      ws.onmessage = function (event) {
        const lines = event.data.split("\r\n");
        lines.forEach(function (line) {
          if (line.trim()) {
            handleMessage(line);
          }
        });
      };

      ws.onerror = function () {
        setStatus("error");
      };

      ws.onclose = function () {
        setStatus("disconnected");
        addMessage("system", "", "Disconnected from server");
        users.clear();
        renderUsers();

        if (reconnectAttempts < MAX_RECONNECT_ATTEMPTS) {
          reconnectAttempts++;
          setStatus("connecting");
          setTimeout(connect, RECONNECT_DELAY);
        } else {
          setStatus("error");
        }
      };
    } catch (e) {
      setStatus("error");
    }
  }

  function sendMessage(text) {
    if (!isConnected || !text.trim()) return;

    sendRaw("PRIVMSG " + CHANNEL + " :" + text);
    addMessage("privmsg", nickname, text);
    inputEl.value = "";
  }

  formEl.addEventListener("submit", function (e) {
    e.preventDefault();
    sendMessage(inputEl.value);
  });

  inputEl.addEventListener("keydown", function (e) {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      sendMessage(inputEl.value);
    }
  });

  connect();
})();
