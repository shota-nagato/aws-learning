import axios, { type AxiosInstance } from 'axios'
import { fetchAuthSession } from 'aws-amplify/auth'

import logger from './logger'
import { getEnv } from './env'

const API_URL = getEnv('VITE_API_URL')

const getIdToken = async (): Promise<string | null> => {
  try {
    const session = await fetchAuthSession()
    const token = session.tokens?.idToken?.toString()
    return token ?? null
  } catch (err) {
    logger.warn("認証情報の取得に失敗しました", err)
    return null
  }
}

export const apiV1Client: AxiosInstance = axios.create({
  baseURL: `${API_URL}/v1`,
  timeout: 10000,
})

apiV1Client.defaults.headers.common["Content-Type"] = "application/json"

apiV1Client.interceptors.request.use(
  async (config) => {
    const token = await getIdToken()

    if (!token) {
      logger.warn("APIリクエストにトークンがありません")
      return Promise.reject(new axios.Cancel("No auth token"))
    }

    config.headers["Authorization"] = `Bearer ${token}`
    return config
  },
  (error) => Promise.reject(error)
)
