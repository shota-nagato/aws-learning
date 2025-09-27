export const getEnv = (key: string, defaultValue?: string): string => {
  const value = import.meta.env[key] ?? defaultValue
  if (!value) {
    throw new Error(`Environment variable ${key} is not defined`)
  }
  return value
}
