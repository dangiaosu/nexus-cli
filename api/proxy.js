// api/proxy.js
export default async function handler(req, res) {
  // CORS headers
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Accept, Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { walletAddress } = req.query;

  if (!walletAddress) {
    return res.status(400).json({ error: 'walletAddress parameter is required' });
  }

  console.log(`Checking wallet: ${walletAddress}`);

  try {
    const targetUrl = `https://loyalty.campnetwork.xyz/api/users?walletAddress=${walletAddress}`;
    
    const response = await fetch(targetUrl, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive',
        'Sec-Ch-Ua': '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
        'Sec-Ch-Ua-Mobile': '?0',
        'Sec-Ch-Ua-Platform': '"Windows"',
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'cross-site'
      }
    });

    console.log(`Response status: ${response.status}`);

    if (!response.ok) {
      const errorText = await response.text();
      console.error(`API Error: ${response.status} - ${errorText}`);
      
      return res.status(response.status).json({ 
        error: `Camp Network API returned ${response.status}`,
        details: errorText 
      });
    }

    const data = await response.json();
    console.log('Success! Data received');
    
    return res.status(200).json(data);

  } catch (error) {
    console.error('Proxy error:', error);
    
    return res.status(500).json({ 
      error: 'Internal server error', 
      details: error.message,
      timestamp: new Date().toISOString()
    });
  }
}
