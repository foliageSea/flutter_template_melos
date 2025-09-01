import {
    AudioWaveform,
    Command,
    GalleryVerticalEnd,
    AppWindowIcon
} from 'lucide-vue-next'

import {useSidebar} from '@/composables/use-sidebar'

import type {SidebarData, Team, User} from '../types'

const user: User = {
    name: 'shadcn',
    email: 'm@example.com',
    avatar: '/avatars/shadcn.jpg',
}

const teams: Team[] = [
    {
        name: 'Flutter Template',
        logo: AppWindowIcon,
        plan: '后台管理',
    },
    // {
    //   name: 'Acme Corp.',
    //   logo: AudioWaveform,
    //   plan: 'Startup',
    // },
    // {
    //   name: 'Evil Corp.',
    //   logo: Command,
    //   plan: 'Free',
    // },
]

const {navData} = useSidebar()

export const sidebarData: SidebarData = {
    user,
    teams,
    navMain: navData.value!,
}
