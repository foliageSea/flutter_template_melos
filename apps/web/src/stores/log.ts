import {defineStore} from "pinia";
import {useLogApi} from '@/services/api/log.api.ts'

export const useLogStore = defineStore('log', () => {

    let logs = ref([])

    let logApi = useLogApi();

    async function getLogs() {
        let resp = await logApi.list();

        logs.value = resp.data;

    }


    return {
        getLogs,
        logs
    }
})