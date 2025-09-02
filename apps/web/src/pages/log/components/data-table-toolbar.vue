<script setup lang="ts">
import {Button} from '@/components/ui/button'
import {useLogStore} from '@/stores/log.ts'

</script>

<template>
  <div class="flex items-center justify-between">
    <div class="flex flex-col items-start flex-1 space-y-2 md:items-center md:space-x-2 md:space-y-0 md:flex-row">

      <Button
          class="h-8 px-2 lg:px-3"
          @click="useLogStore().getLogs"
      >
        刷新
      </Button>
    </div>

  </div>
</template>
