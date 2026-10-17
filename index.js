const express = require('express');
const axios = require('axios');
const app = express();

app.use(express.json());

const DISCORD_WEBHOOK_URL = 'https://discord.com/api/webhooks/1560887468142628866/Zb7NBazwxaqyYFmA_MapEfpB6n5MApWNKkYx2zS8gxLxH30rxJWQbk1CAljbOSwOCMS9';

app.post('/log', async (req, res) => {
    const { player, userId, gameName, placeId, age } = req.body;

    if (!player) {
        return res.status(400).json({ error: "No player name" });
    }

    const embed = {
        title: "Zrzocks Hub Executed",
        color: 16711680,
        description: `**Player:** ${player}\n**Game:** ${gameName || 'Unknown'}`,
        fields: [
            { name: "User ID", value: `\`${userId}\``, inline: true },
            { name: "Account Age", value: `${age} days`, inline: true },
            { name: "Place ID", value: `\`${placeId}\``, inline: true }
        ],
        timestamp: new Date().toISOString(),
        footer: { text: "Zrzocks Logger" }
    };

    try {
        await axios.post(DISCORD_WEBHOOK_URL, {
            content: "**Zrzocks Hub Executed**",
            embeds: [embed]
        });
        res.status(200).json({ success: true });
    } catch (error) {
        console.error(error.message);
        res.status(500).json({ error: error.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Logger running on port ${PORT}`);
});
