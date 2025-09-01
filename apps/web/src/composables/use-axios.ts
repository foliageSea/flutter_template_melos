import type {AxiosError} from 'axios'

import axios from 'axios'

import env from '@/utils/env'
import {toast} from 'vue-sonner'
import {useAuthStore} from '@/stores/auth.ts'


export function useAxios() {
    const axiosInstance = axios.create({
        baseURL: env.VITE_SERVER_API_URL + env.VITE_SERVER_API_PREFIX,
        timeout: env.VITE_SERVER_API_TIMEOUT,
    })

    axiosInstance.interceptors.request.use((config) => {
        let token = useAuthStore().token
        if (token) {
            config.headers['Authorization'] = 'Bearer ' + token
        }
        return config
    }, (error) => {
        return Promise.reject(error)
    })

    axiosInstance.interceptors.response.use((response) => {
        return response.data
    }, (error: AxiosError) => {
        // if status is not 2xx, throw error
        // you can handle error here

        if (error.response?.status === 401) {
            useAuthStore().clearToken();
        }

        // @ts-ignore
        let message = error.response?.data?.message ?? error.message
        toast.warning(message)
        return Promise.reject(error)
    })

    return {
        axiosInstance,
    }
}


export const {axiosInstance: request} = useAxios()
