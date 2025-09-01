import {useAuthStore} from '@/stores/auth.ts'
import {toast} from 'vue-sonner'

export function useAuth() {
    const router = useRouter()
    const authStore = useAuthStore()

    async function logout() {
        authStore.clearToken()
        await router.push({path: '/auth/sign-in'})
        toast.success('退出登录')
    }

    function toHome() {
        router.push({path: '/workspace'})
    }

    function login() {
        toHome()
    }

    return {
        logout,
        login,
    }
}
