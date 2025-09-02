export function useLogApi() {

    const controller = '/log'

    async function list() {
        return request.get(`${controller}/list`)
    }


    return {
        list
    }
}