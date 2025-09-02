<script setup lang="ts">
import {onMounted, toRefs} from 'vue'
import Page from "@/components/global-layout/basic-page.vue";
import {useLogStore} from '@/stores/log.ts'
import DataTable from './components/data-table.vue'
import {columns} from './components/columns.ts'
import DataTableToolbar from './components/data-table-toolbar.vue'
import {useAuthStore} from '@/stores/auth.ts'


let logStore = useLogStore();

const {logs} = toRefs(logStore)

onMounted(async () => {
  await logStore.getLogs();


  const token = useAuthStore().token

  const socket = new WebSocket(`ws://localhost:8081?token=${token}`);


  socket.addEventListener("message", (event) => {
    // console.log("Message from server ", event.data);
    let data = JSON.parse(event.data);
    if (data.type === 'customMessage') {
      if (data.data.customType === 'logger') {
        console.log(data.data.customData);
        logs.value.push(data.data.customData);
      }
    }
  });
  socket.addEventListener("close", (event) => {
    console.log("Connection closed ", event);
  });

})

</script>

<template>
  <Page
      title="日志"
      description="应用日志"
      sticky
  >
    <template #actions>
      <DataTableToolbar/>
    </template>
    <div class="overflow-x-auto">
      <DataTable :data="logs" :columns="columns"/>
    </div>
  </Page>
</template>

<style scoped>

</style>