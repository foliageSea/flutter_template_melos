<script setup lang="ts">
import type {DataTableProps} from '@/components/data-table/types'
import DataTable from '@/components/data-table/data-table.vue'
import {generateVueTable} from '@/components/data-table/use-generate-vue-table'
import {Log} from "@/pages/log/data/schema.ts";

const props = defineProps<DataTableProps<Log>>()
const table = generateVueTable<Log>(props)
</script>

<template>
  <DataTable :columns :table :data :loading>

  </DataTable>
</template>
