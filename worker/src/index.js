const ALLOWED_ORIGINS = [
  "https://dieman.dev",
];

function getCorsHeaders(origin) {
  return {
    "Access-Control-Allow-Origin": origin,
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
  };
}

function jsonResponse(data, origin, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json", ...getCorsHeaders(origin) },
  });
}

export default {
  async fetch(request, env) {
    const origin = request.headers.get("Origin") || ALLOWED_ORIGINS[0];
    const isAllowed = ALLOWED_ORIGINS.includes(origin);

    if (request.method === "OPTIONS") {
      if (!isAllowed) return new Response(null, { status: 403 });
      return new Response(null, { headers: getCorsHeaders(origin) });
    }

    if (!isAllowed) {
      return jsonResponse({ error: "Forbidden" }, origin, 403);
    }

    const url = new URL(request.url);
    const path = url.pathname;

    // Hearts endpoint
    const heartsMatch = path.match(/^\/api\/hearts\/(.+)$/);
    if (heartsMatch) {
      const postId = decodeURIComponent(heartsMatch[1]);
      const key = `hearts:${postId}`;

      if (request.method === "GET") {
        const count = await env.HEART_COUNTS.get(key);
        return jsonResponse({ count: parseInt(count || "0", 10) }, origin);
      }

      if (request.method === "POST") {
        const current = parseInt((await env.HEART_COUNTS.get(key)) || "0", 10);
        const newCount = current + 1;
        await env.HEART_COUNTS.put(key, newCount.toString());
        return jsonResponse({ count: newCount }, origin);
      }

      return jsonResponse({ error: "Method not allowed" }, origin, 405);
    }

    // Views endpoint
    const viewsMatch = path.match(/^\/api\/views\/(.+)$/);
    if (viewsMatch) {
      const postId = decodeURIComponent(viewsMatch[1]);
      const key = `views:${postId}`;

      if (request.method === "GET") {
        const count = await env.HEART_COUNTS.get(key);
        return jsonResponse({ count: parseInt(count || "0", 10) }, origin);
      }

      if (request.method === "POST") {
        const current = parseInt((await env.HEART_COUNTS.get(key)) || "0", 10);
        const newCount = current + 1;
        await env.HEART_COUNTS.put(key, newCount.toString());
        return jsonResponse({ count: newCount }, origin);
      }

      return jsonResponse({ error: "Method not allowed" }, origin, 405);
    }

    return jsonResponse({ error: "Not found" }, origin, 404);
  },
};
