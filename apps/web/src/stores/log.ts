import {defineStore} from "pinia";
import {useLogApi} from '@/services/api/log.api.ts'


export interface Log {
    message: string;
    logLevel: string;
    example: string;
    error: string;
    stackTrace: string;
    title: string;
    time: string;
}


export const useLogStore = defineStore('log', () => {

    let logs = ref<Log[]>([])

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