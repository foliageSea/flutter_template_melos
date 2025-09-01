import {defineStore} from 'pinia'
import {computed, ref} from 'vue'
import {useUserApi} from '@/services/api/user.api.ts'

export interface UserInfo {
    id: number,
    username: string,
    name: string,
    isAdmin: boolean,
    avatar: string | null
}


export const useAuthStore = defineStore('user', () => {

    const userApi = useUserApi();


    const isLogin = computed(() => {
        return token.value !== ''
    })
    const token = ref('')
    const userInfo = ref<UserInfo>({})

    function clearToken() {
        token.value = ''
        userInfo.value = {}
    }

    async function getUserInfo() {
        let resp = await userApi.getUserInfo();
        userInfo.value = resp.data
    }


    return {
        isLogin,
        token,
        clearToken,
        userInfo,
        getUserInfo
    }
}, {
    persist: {
        pick: ['token']
    },
})
