export function formatAiError(err, detail) {
    if (typeof err === 'string' && err.trim()) return err.trim();
    if (detail && typeof detail === 'string') return detail;
    try {
        if (typeof err === 'object' && err) {
            const msg = err.error || err.message || JSON.stringify(err);
            return String(msg);
        }
    } catch (_) {}
    return '请求失败，请稍后重试';
}
