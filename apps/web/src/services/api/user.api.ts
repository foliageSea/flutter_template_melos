import {request} from '@/composables/use-axios.ts'


export function useUserApi() {
    const controller = '/user'

    function login(data: any) {
        return request.post(`${controller}/login`, data)
    }


    function getUserInfo() {
        return request.get(`${controller}/info`)
    }


    return {
        login,
        getUserInfo
    }
}