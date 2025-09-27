import { getEnv } from "./env";

const isDev = getEnv("MODE", "development") === "development"

const logger = {
  debug: (...args: unknown[]) =>
    isDev &&
    console.info("%c[DEBUG]", "color: gray; font-weight: bold;", ...args),

  info: (...args: unknown[]) =>
    isDev &&
    console.info("%c[INFO]", "color: dodgerblue; font-weight: bold;", ...args),

  warn: (...args: unknown[]) =>
    console.warn("%c[WARN]", "color: orange; font-weight: bold;", ...args),

  error: (...args: unknown[]) =>
    console.error("%c[ERROR]", "color: red; font-weight: bold;", ...args),
}

export default logger
