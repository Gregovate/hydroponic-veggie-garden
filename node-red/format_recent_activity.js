const rows = Array.isArray(msg.payload) ? msg.payload : [];

function fmtNum(v, decimals) {
    const n = Number(v);
    return Number.isFinite(n) ? n.toFixed(decimals) : null;
}

function fmtDate(v) {
    if (!v) return "";

    const d = new Date(v);
    if (Number.isNaN(d.getTime())) return String(v);

    return d.toLocaleString("en-US", {
        weekday: "short",
        month: "short",
        day: "numeric",
        hour: "numeric",
        minute: "2-digit",
        hour12: true
    });
}

const lines = rows.map(r => {
    const details = [];

    if (fmtNum(r.fill_gallons, 2)) details.push(`Fill: ${fmtNum(r.fill_gallons, 2)} gal`);
    if (fmtNum(r.dose_a_ml, 0)) details.push(`A: ${fmtNum(r.dose_a_ml, 0)} mL`);
    if (fmtNum(r.dose_b_ml, 0)) details.push(`B: ${fmtNum(r.dose_b_ml, 0)} mL`);
    if (fmtNum(r.tds_voltage, 3)) details.push(`TDS: ${fmtNum(r.tds_voltage, 3)} V`);
    if (fmtNum(r.tank_gallons, 1)) details.push(`Tank: ${fmtNum(r.tank_gallons, 1)} gal`);
    if (fmtNum(r.water_temp_f, 1)) details.push(`Temp: ${fmtNum(r.water_temp_f, 1)} °F`);

    let line = `### #${r.source_id} — ${r.event_type || "EVENT"}\n`;
    line += `**${fmtDate(r.activity_time)}**`;
    if (r.source) line += ` · ${r.source}`;
    line += `\n\n`;

    if (details.length) {
        line += details.join(" · ") + "\n\n";
    }

    if (r.note) {
        line += `${String(r.note).slice(0, 240)}\n`;
    }
    
    if (r.operator_note) {
        line += `\n**Operator Note:** ${String(r.operator_note).slice(0, 240)}\n`;
    }
    return line;
});

const activityText = lines.join("\n---\n");

msg.payload = JSON.stringify({
    state: "ok",
    activity_text: activityText,
    records: rows,
    updated_at: new Date().toISOString()
});

return msg;