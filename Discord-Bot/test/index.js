const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const { createRequire } = require("node:module");
const { EventEmitter } = require("node:events");
const discord = require("discord.js");

function loadScript(file, overrides = {}, env = {}) {
    const filename = path.join(__dirname, "../src", file);
    const localRequire = createRequire(filename);
    const messages = [];
    const context = {
        module: { exports: {} },
        __dirname: path.dirname(filename),
        Buffer, setTimeout, clearTimeout,
        process: { env, exitCode: 0, exit(code) { throw new Error(`exit:${code}`); } },
        console: { log(...args) { messages.push(args); }, warn(...args) { messages.push(args); }, error(...args) { messages.push(args); } },
        require(name) {
            if (Object.hasOwn(overrides, name)) return overrides[name];
            if (name === "dotenv") return { config() { return {}; } };
            return localRequire(name);
        }
    };
    vm.runInNewContext(fs.readFileSync(filename, "utf8"), context, { filename });
    return { exports: context.module.exports, context, messages };
}

function makeInteraction(username = "John_Doe", discordId = "123456789012345678") {
    return {
        user: { id: discordId },
        fields: { getTextInputValue() { return username; } },
        calls: [],
        deferred: false,
        replied: false,
        async deferReply(options) { this.deferred = true; this.calls.push({ method: "deferReply", options }); },
        async editReply(options) { assert.ok(this.deferred); this.replied = true; this.calls.push({ method: "editReply", options }); },
        async reply(options) { this.replied = true; this.calls.push({ method: "reply", options }); },
        async followUp(options) { this.calls.push({ method: "followUp", options }); },
        async showModal(modal) { this.calls.push({ method: "showModal", modal: modal.toJSON() }); }
    };
}

function loadModal(execute) {
    return loadScript("modals/ModalRegister.js", { "../mysql": { execute } }).exports;
}

test("Pendaftaran menyimpan kode 6 digit dan menunggu insert sebelum mengirim sukses", async () => {
    const interaction = makeInteraction("  John_Doe  ");
    let inserted;
    const modal = loadModal(async (sql, params) => {
        assert.equal(interaction.calls[0].method, "deferReply");
        assert.equal(interaction.calls[0].options.flags, discord.MessageFlags.Ephemeral);
        if (!sql.startsWith("INSERT")) return [[]];
        assert.equal(interaction.calls.length, 1);
        assert.match(sql, /VALUES \(\?, \?, \?, 0\)/);
        inserted = params;
        return [{ affectedRows: 1, insertId: 1 }];
    });
    await modal.run({}, interaction);
    assert.equal(inserted[0], interaction.user.id);
    assert.equal(inserted[1], "John_Doe");
    assert.ok(Number.isInteger(inserted[2]) && inserted[2] >= 100000 && inserted[2] <= 999999);
    const embed = interaction.calls.at(-1).options.embeds[0].toJSON();
    assert.equal(embed.title, "✅ Pendaftaran Berhasil!");
    assert.equal(embed.fields[1].value, `\`${inserted[2]}\``);
});

test("Nama tidak valid ditolak tanpa insert", async () => {
    for (const username of ["john_Doe", "John_doe", "John Doe", "John_Doe'", "John_" + "D".repeat(20)]) {
        let queries = 0;
        const modal = loadModal(async () => { queries++; return [[]]; });
        const interaction = makeInteraction(username);
        await modal.run({}, interaction);
        assert.equal(queries, 1);
        assert.match(interaction.calls.at(-1).options.content, /Format nama tidak valid/);
    }
});

test("Discord ID dan nama yang sudah terdaftar ditolak", async () => {
    for (const existingDiscord of [true, false]) {
        const modal = loadModal(async (sql) => {
            assert.ok(!sql.startsWith("INSERT"));
            return [sql.includes("discordid") && !existingDiscord ? [] : [{ id: 1, nama: "John_Doe" }]];
        });
        const interaction = makeInteraction();
        await modal.run({}, interaction);
        assert.match(interaction.calls.at(-1).options.content, existingDiscord ? /Akun Discord kamu sudah terdaftar/ : /sudah digunakan/);
    }
});

test("Insert gagal tidak mengirim pesan pendaftaran berhasil", async () => {
    const error = new Error("Database unavailable");
    const modal = loadModal(async (sql) => {
        if (sql.startsWith("INSERT")) throw error;
        return [[]];
    });
    const interaction = makeInteraction();
    await assert.rejects(modal.run({}, interaction), error);
    assert.equal(interaction.calls.length, 1);
});

for (const sameDiscord of [true, false]) {
    test(`Pendaftaran bersamaan dengan ${sameDiscord ? "Discord ID" : "nama"} yang sama hanya menyimpan satu akun`, async () => {
        const players = [];
        let release;
        let checks = 0;
        const barrier = new Promise(resolve => { release = resolve; });
        const modal = loadModal(async (sql, params) => {
            if (sql.startsWith("INSERT")) {
                if (players.some(player => player.discordid === params[0] || player.nama === params[1])) {
                    throw Object.assign(new Error("Duplicate entry"), { code: "ER_DUP_ENTRY" });
                }
                players.push({ discordid: params[0], nama: params[1] });
                return [{ affectedRows: 1 }];
            }
            if (sql.startsWith("SELECT id FROM Pemain WHERE nama")) {
                if (checks >= 2) return [players.filter(player => player.nama === params[0])];
                if (++checks === 2) release();
                await barrier;
                return [[]];
            }
            return [players.filter(player => player.discordid === params[0])];
        });
        const first = makeInteraction();
        const second = makeInteraction(sameDiscord ? "Jane_Doe" : "John_Doe", sameDiscord ? first.user.id : "223456789012345678");
        await Promise.all([modal.run({}, first), modal.run({}, second)]);
        assert.equal(players.length, 1);
        const responses = [first, second].map(interaction => interaction.calls.at(-1).options);
        assert.equal(responses.filter(response => response.embeds).length, 1);
        assert.equal(responses.filter(response => response.content).length, 1);
    });
}

test("Tombol menampilkan status belum verifikasi walaupun database mengembalikan string 0", async () => {
    const pool = { async execute() { return [[{ nama: "John_Doe", kode: 123456, verified: "0" }]]; } };
    const button = loadScript("buttons/TestRegister.js", { "../mysql": pool }).exports;
    const interaction = makeInteraction();
    await button.run({}, interaction);
    assert.match(interaction.calls[0].options.content, /Belum Verifikasi di In-Game/);
    assert.equal(interaction.calls[0].options.flags, discord.MessageFlags.Ephemeral);
});

test("Tombol tetap membuka modal sebelum batas Discord saat database lambat", async () => {
    let rejectQuery;
    const pool = { execute() { return new Promise((resolve, reject) => { rejectQuery = reject; }); } };
    const button = loadScript("buttons/TestRegister.js", { "../mysql": pool }).exports;
    const interaction = makeInteraction();
    await button.run({}, interaction);
    assert.equal(interaction.calls[0].method, "showModal");
    assert.equal(interaction.calls[0].modal.custom_id, "reg_modal");
    rejectQuery(new Error("Late database failure"));
});

test("Konfigurasi DB_* didahulukan dan USER dari .env tidak tertimpa USER sistem", () => {
    for (const prefixed of [true, false]) {
        let config;
        const script = loadScript("mysql.js", {
            dotenv: { config(options) { assert.equal(options.path, path.join(__dirname, "../.env")); return { parsed: { USER: "legacy_user", PORT: "3307" } }; } },
            "mysql2/promise": { createPool(options) { config = options; return {}; } }
        }, { USER: "linux_user", PORT: "8080", ...(prefixed ? { DB_USER: "bot_user", DB_PORT: "3308", DB_PASSWORD: "" } : {}) });
        assert.equal(config.user, prefixed ? "bot_user" : "legacy_user");
        assert.equal(config.port, prefixed ? 3308 : 3307);
        assert.equal(config.password, "");
        assert.equal(script.messages.length, 0);
    }
});

function loadBot(pool, env = { TOKEN: "test-token" }) {
    let client;
    class FakeClient extends EventEmitter {
        constructor() { super(); client = this; }
        async login() { this.loggedIn = true; }
        destroy() { this.destroyed = true; }
    }
    const script = loadScript("index.js", {
        "discord.js": { ...discord, Client: FakeClient },
        "./mysql": pool,
        "./handler/loadCommand": () => {},
        "./handler/loadButton": () => {},
        "./handler/loadModal": () => {}
    }, env);
    return { ...script, client };
}

test("Startup mengecek database dan berhenti jika koneksi atau index tidak tersedia", async () => {
    for (const state of ["connected", "missing-index", "offline", "missing-token"]) {
        let closed = false;
        const bot = loadBot({
            async query(sql) {
                if (state === "offline") throw new Error("Connection refused");
                if (sql.startsWith("SHOW")) return [state === "missing-index" ? [] : [{ Non_unique: 0, Column_name: "discordid", Key_name: "unique_discord" }]];
                return [[]];
            },
            async end() { closed = true; }
        }, state === "missing-token" ? {} : { TOKEN: "test-token" });
        await new Promise(setImmediate);
        assert.equal(Boolean(bot.client.loggedIn), state === "connected");
        assert.equal(closed, state !== "connected");
        assert.equal(bot.context.process.exitCode, state === "connected" ? 0 : 1);
        if (state === "offline") assert.ok(!bot.messages.some(message => message[0] === "[DTRP-BOT] Database connected!"));
    }
});

test("Error setelah defer menyelesaikan respons awal yang sedang menunggu", async () => {
    const bot = loadBot({ async query() { return [[{ Non_unique: 0, Column_name: "discordid", Key_name: "unique_discord" }]]; } });
    await new Promise(setImmediate);
    bot.client.modals.set("reg_modal", { async run() { throw new Error("Insert failed"); } });
    const interaction = makeInteraction();
    interaction.deferred = true;
    interaction.customId = "reg_modal";
    interaction.isChatInputCommand = () => false;
    interaction.isButton = () => false;
    interaction.isModalSubmit = () => true;
    await bot.client.listeners("interactionCreate")[0](interaction);
    assert.equal(interaction.calls[0].method, "editReply");
    assert.equal(interaction.calls[0].options.content, "Terjadi error saat memproses interaksi!");
});

test("Deploy menolak ID tidak valid dan melaporkan exit code saat API gagal", async () => {
    assert.throws(() => loadScript("deployCommands.js"), /exit:1/);
    assert.throws(() => loadScript("deployCommands.js", {}, { TOKEN: "invalid" }), /exit:1/);
    assert.throws(() => loadScript("deployCommands.js", {}, { TOKEN: "test-token", CLIENT_ID: "invalid" }), /exit:1/);
    for (const fail of [true, false]) {
        let route;
        class FakeREST {
            setToken() { return this; }
            async put(url, options) { route = url; assert.equal(options.body[0].name, "register"); if (fail) throw new Error("API unavailable"); return options.body; }
        }
        const script = loadScript("deployCommands.js", { "discord.js": { ...discord, REST: FakeREST } }, { TOKEN: "test-token", CLIENT_ID: "123456789012345678", ...(fail ? { GUILD_ID: "223456789012345678" } : {}) });
        await new Promise(setImmediate);
        assert.equal(script.context.process.exitCode, fail ? 1 : 0);
        assert.equal(route, fail ? "/applications/123456789012345678/guilds/223456789012345678/commands" : "/applications/123456789012345678/commands");
    }
});

test("querySAMP mengembalikan data server online dan offline", async () => {
    const fakeGameDig = {
        async query({ type }) {
            if (type === "gtasao") {
                return {
                    name: "Detroit Roleplay",
                    game: "open.mp",
                    numplayers: 2,
                    maxplayers: 50,
                    ping: 25,
                    players: [{ name: "Admin" }, { name: "Player" }],
                    raw: { gamemode: "Roleplay", rules: { mapname: "Detroit" } }
                };
            }
            throw new Error("Query failed");
        }
    };
    const queryScript = loadScript("query.js", { gamedig: { GameDig: fakeGameDig } }).exports;
    const resultOnline = await queryScript.querySAMP("127.0.0.1", 7777);
    assert.equal(resultOnline.online, true);
    assert.equal(resultOnline.players, 2);
    assert.equal(resultOnline.maxPlayers, 50);
    assert.equal(resultOnline.gamemode, "Roleplay");
    assert.equal(resultOnline.map, "Detroit");

    const failingGameDig = {
        async query() {
            throw new Error("Connection timed out");
        }
    };
    const queryFailScript = loadScript("query.js", { gamedig: { GameDig: failingGameDig } }).exports;
    const resultOffline = await queryFailScript.querySAMP("127.0.0.1", 7777);
    assert.equal(resultOffline.online, false);
    assert.equal(resultOffline.players, 0);
    assert.equal(resultOffline.maxPlayers, 0);
});

test("Command status mengembalikan embed online dan offline", async () => {
    const onlineQuery = async () => ({
        online: true,
        name: "Detroit Roleplay Project",
        gamemode: "DTRP v1.0",
        map: "San Andreas",
        players: 5,
        maxPlayers: 100,
        ping: 30,
        playerList: ["Player_One", "Player_Two"]
    });
    const statusOnline = loadScript("commands/status.js", { "../query": { querySAMP: onlineQuery } }).exports;
    const interaction1 = makeInteraction();
    await statusOnline.run({}, interaction1);
    assert.equal(interaction1.calls[0].method, "deferReply");
    assert.equal(interaction1.calls[1].method, "editReply");
    const embed1 = interaction1.calls[1].options.embeds[0].toJSON();
    assert.equal(embed1.title, "🎮 Detroit Roleplay Project");
    assert.equal(embed1.color, 0x57F287);

    const offlineQuery = async () => ({
        online: false,
        name: "Unknown",
        gamemode: "Unknown",
        map: "Unknown",
        players: 0,
        maxPlayers: 0,
        ping: 0,
        playerList: []
    });
    const statusOffline = loadScript("commands/status.js", { "../query": { querySAMP: offlineQuery } }).exports;
    const interaction2 = makeInteraction();
    await statusOffline.run({}, interaction2);
    const embed2 = interaction2.calls[1].options.embeds[0].toJSON();
    assert.equal(embed2.title, "🔴 Server Offline");
    assert.equal(embed2.color, 0xED4245);
});

