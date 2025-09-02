import type {ColumnDef} from "@tanstack/vue-table";
import {SelectColumn} from "@/components/data-table/table-columns.ts";
import {Log} from "@/pages/log/data/schema.ts";
import {h} from "vue";
import DataTableColumnHeader from "@/components/data-table/column-header.vue";

export const columns: ColumnDef<Log>[] = [
    SelectColumn as ColumnDef<Log>,
    {
        accessorKey: 'title',
        header: ({column}) => h(DataTableColumnHeader<Log>, {column, title: '标题'}),
        cell: ({row}) => {
            return h('div', {}, row.getValue('title'))
        },
    },
    {
        accessorKey: 'message',
        header: ({column}) => h(DataTableColumnHeader<Log>, {column, title: '信息'}),
        cell: ({row}) => {
            return h('div', {class: 'max-w-[500px] truncate font-medium'}, row.getValue('message'))
        },


    },
    {
        accessorKey: 'logLevel',
        header: ({column}) => h(DataTableColumnHeader<Log>, {column, title: '等级'}),
        cell: ({row}) => {
            return h('div', {}, row.getValue('logLevel'))
        },
    },

    {
        accessorKey: 'time',
        header: ({column}) => h(DataTableColumnHeader<Log>, {column, title: '时间'}),
        cell: ({row}) => {
            return h('div', {}, row.getValue('time'))
        },
    }

]