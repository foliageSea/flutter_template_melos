<script lang="ts" setup>
import {ref} from 'vue'
import {useUserApi} from '@/services/api/user.api.ts'
import {useAuthStore} from '@/stores/auth.ts'
import {toast} from 'vue-sonner'
import {useRouter} from 'vue-router'

const userApi = useUserApi();
const authStore = useAuthStore();
const router = useRouter()

const form = ref({
  username: 'admin',
  password: 'admin',
})

async function login() {
  let resp = await userApi.login(form.value);
  console.log('登录成功')

  let token = resp.data.token;

  authStore.token = token;

  await router.push('/')

  toast.success('登录成功');

  await authStore.getUserInfo()

}


</script>

<template>
  <UiCard class="w-full max-w-sm">
    <UiCardHeader>
      <UiCardTitle class="text-2xl">
        登录
      </UiCardTitle>
    </UiCardHeader>
    <UiCardContent class="grid gap-4">
      <div class="grid gap-2">
        <UiLabel for="email">
          用户名
        </UiLabel>
        <UiInput v-model:model-value="form.username" id="username" placeholder="请输入用户名" required/>
      </div>
      <div class="grid gap-2">
        <div class="flex items-center justify-between">
          <UiLabel for="password">
            密码
          </UiLabel>
        </div>
        <UiInput v-model:model-value="form.password" id="password" type="password" required placeholder="请输入密码"/>
      </div>

      <UiButton class="w-full" @click="login">
        登录
      </UiButton>
    </UiCardContent>
  </UiCard>
</template>

<style scoped>

</style>
