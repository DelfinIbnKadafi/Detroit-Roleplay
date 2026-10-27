// script samp-query by lumyralabs
const { GameDig } = require('gamedig');

/**
 * Query SA-MP / open.mp server.
 */
async function querySAMP(host, port) {
    const types = ['gtasao', 'gtasam']; // type diambil dari docs gamedig langsung

    for (const type of types) {
        try {
            const state = await GameDig.query({
                type,
                host,
                port: parseInt(port),
                timeout: 5000,
            }); // start query

            return {
                online: true,
                name: state.name ?? 'Unknown',
                gamemode: state.raw?.gamemode ?? state.game ?? 'Unknown',
                map: state.raw?.rules?.mapname ?? 'Unknown',
                players: state.numplayers ?? state.players?.length ?? 0,
                maxPlayers: state.maxplayers ?? 0,
                ping: state.ping ?? 0,
                playerList: (state.players ?? []).map(p => p.name).filter(Boolean),
            };
        } catch (err) {
            // untuk lihat error diconsole jika gagal
        }
    }

    return {
        online: false,
        name: 'Unknown',
        gamemode: 'Unknown',
        map: 'Unknown',
        players: 0,
        maxPlayers: 0,
        ping: 0,
        playerList: [],
    };
}

module.exports = { querySAMP }; // export global biar bisa dibaca file lain
