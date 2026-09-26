// pi-cursor-status — zeigt die von nvim geschriebene Cursor-/Selektions-
// Statusdatei ($XDG_RUNTIME_DIR/pi-cursor-status.txt, siehe nixvim
// config/ai/pi-x-ide.nix) als Statuszeile in pi. NUR Anzeige, keine
// Kontext-Injektion (die uebernimmt pi-x-ide).
import { existsSync, statSync, readFileSync } from "node:fs";

export default function (pi: any) {
	const g = globalThis as any;
	if (g.__piCursorStatusTimer) clearInterval(g.__piCursorStatusTimer);
	let activeCtx: any = null;
	pi.on("session_start", (_ev: any, ctx: any) => { activeCtx = ctx; });
	const file = (process.env.XDG_RUNTIME_DIR || "/tmp") + "/pi-cursor-status.txt";
	const timer = setInterval(() => {
		const ctx = activeCtx;
		if (!ctx || !ctx.ui) return;
		try {
			if (!existsSync(file)) return;
			const st = statSync(file);
			if (Date.now() - st.mtimeMs > 10 * 60 * 1000) {
				ctx.ui.setStatus("pi-cursor", null); // nvim weg/idle >10 min
				return;
			}
			ctx.ui.setStatus("pi-cursor", readFileSync(file, "utf-8").trim());
		} catch { /* UI weg (reload/headless): ignorieren */ }
	}, 500);
	if (typeof timer.unref === "function") timer.unref();
	g.__piCursorStatusTimer = timer;
}
