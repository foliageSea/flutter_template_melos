<script lang="ts" setup>
import {sidebarData} from './data/sidebar-data'
import NavFooter from './nav-footer.vue'
import NavTeam from './nav-team.vue'
import TeamSwitcher from './team-switcher.vue'
import {useAuthStore} from '@/stores/auth.ts'

let authStore = useAuthStore();


</script>

<template>
  <UiSidebar collapsible="icon" class="z-50">
    <UiSidebarHeader>
      <TeamSwitcher :teams="sidebarData.teams"/>
    </UiSidebarHeader>

    <UiSidebarContent>
      <NavTeam :nav-main="sidebarData.navMain"/>
    </UiSidebarContent>

    <UiSidebarFooter>
      <NavFooter :user="authStore.userInfo"/>
    </UiSidebarFooter>

    <UiSidebarRail/>
  </UiSidebar>
</template>

<style></style>
