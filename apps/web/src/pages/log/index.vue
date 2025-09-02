<script setup lang="ts">
import {onMounted, toRefs, onBeforeUnmount, ref, nextTick} from 'vue'
import Page from "@/components/global-layout/basic-page.vue";
import {useLogStore} from '@/stores/log.ts'
import {useAuthStore} from '@/stores/auth.ts'
import {Trash2, ArrowUp, ArrowDown, Pause, RotateCcw} from 'lucide-vue-next'


let logStore = useLogStore();

const {logs} = toRefs(logStore)

let socket: WebSocket | null = null
let timer: number = 0
const logContainer = ref<HTMLElement | null>(null)
const isAutoScroll = ref(true)
const scrollPercent = ref(0)

// 构建WebSocket URL
function buildWebSocketUrl(token: string): string {
  // 生产环境使用当前域名
  const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
  const host = window.location.hostname;
  const port = import.meta.env.VITE_WEB_SOCKET_PORT
  return `${protocol}//${host}:${port}?token=${token}`;
}

onMounted(async () => {
  await logStore.getLogs();

  // 初始化滚动百分比
  nextTick(() => {
    if (logContainer.value && logs.value.length > 0) {
      const {scrollTop, scrollHeight, clientHeight} = logContainer.value;
      const maxScrollTop = Math.max(1, scrollHeight - clientHeight);
      scrollPercent.value = Math.round((scrollTop / maxScrollTop) * 100);
    } else {
      scrollPercent.value = 0;
    }
  });

  autoScrollToBottom()

  const token = useAuthStore().token

  // 构建WebSocket URL
  const wsUrl = buildWebSocketUrl(token);
  console.log('WebSocket 连接地址:', wsUrl);

  socket = new WebSocket(wsUrl);

  socket.addEventListener("open", (event) => {
    console.log("WebSocket 连接已建立", event);
  });

  socket.addEventListener("error", (event) => {
    console.error("WebSocket 连接错误", event);
  });

  socket.addEventListener("message", (event) => {
    let data = JSON.parse(event.data);
    if (data.type === 'customMessage') {
      if (data.data.customType === 'logger') {
        console.log(data.data.customData);
        logs.value.push(data.data.customData);
        nextTick(() => {
          // 自动滚动到底部
          autoScrollToBottom();
        })
      }
    }
  });
  socket.addEventListener("close", (event) => {
    console.log("Connection closed ", event);
  });


  timer = setInterval(() => {
    socket?.send(JSON.stringify({
      type: 'heartbeat',
      data: {},
      timestamp: new Date().toISOString(),
    }));
  }, 10000);
})

onBeforeUnmount(() => {
  clearInterval(timer)
  socket?.close()
})

// 获取日志级别的颜色
function getLogLevelColor(level: string): string {
  switch (level?.toLowerCase()) {
    case 'error':
    case 'fatal':
      return 'text-red-400';
    case 'warn':
    case 'warning':
      return 'text-yellow-400';
    case 'info':
      return 'text-blue-400';
    case 'debug':
      return 'text-green-400';
    case 'trace':
      return 'text-gray-400';
    default:
      return 'text-gray-300';
  }
}

// 格式化时间戳
function formatTime(time: string): string {
  if (!time) return '';
  try {
    const date = new Date(time);
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const logDate = new Date(date.getFullYear(), date.getMonth(), date.getDate());

    // 判断是否为今天
    const isToday = logDate.getTime() === today.getTime();

    if (isToday) {
      // 今天只显示时间
      return date.toLocaleTimeString('zh-CN', {
        hour12: false,
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      });
    } else {
      // 非今天显示日期+时间
      return date.toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false
      }).replace(/\//g, '-');
    }
  } catch {
    return time;
  }
}

// 获取日期标签（用于分组显示）
function getDateLabel(time: string): string {
  if (!time) return '';
  try {
    const date = new Date(time);
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);
    const logDate = new Date(date.getFullYear(), date.getMonth(), date.getDate());

    if (logDate.getTime() === today.getTime()) {
      return '今天';
    } else if (logDate.getTime() === yesterday.getTime()) {
      return '昨天';
    } else {
      return date.toLocaleDateString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit'
      }).replace(/\//g, '-');
    }
  } catch {
    return '';
  }
}

// 判断是否需要显示日期分隔符
function shouldShowDateSeparator(currentLog: any, previousLog: any): boolean {
  if (!previousLog) return true;

  const currentDate = getDateLabel(currentLog.time);
  const previousDate = getDateLabel(previousLog.time);

  return currentDate !== previousDate;
}

// 清空日志
function clearLogs() {
  logs.value = [];
  scrollPercent.value = 0;
}

// 切换自动滚动
function toggleAutoScroll() {
  isAutoScroll.value = !isAutoScroll.value;
}

// 手动滚动棄测
function handleScroll() {
  if (logContainer.value) {
    const {scrollTop, scrollHeight, clientHeight} = logContainer.value;
    // 如果滚动到底部附近（50px内），启用自动滚动
    isAutoScroll.value = scrollHeight - scrollTop - clientHeight < 50;

    // 更新滚动百分比
    const maxScrollTop = Math.max(1, scrollHeight - clientHeight);
    scrollPercent.value = Math.round((scrollTop / maxScrollTop) * 100);
  }
}

// 滚动到顶部
function scrollToTop() {
  const scrollContainer = logContainer.value;
  if (scrollContainer) {
    scrollContainer.scrollTo({top: 0, behavior: 'smooth'});
    // 更新滚动百分比
    scrollPercent.value = 0;
  }
}

// 滚动到底部
function scrollToBottom() {
  const scrollContainer = logContainer.value;
  if (scrollContainer) {
    scrollContainer.scrollTo({top: scrollContainer.scrollHeight, behavior: 'smooth'});
    // 更新滚动百分比
    scrollPercent.value = 100;
  }
}

// 自动滚动到底部（新日志时）
function autoScrollToBottom() {
  if (isAutoScroll.value && logContainer.value) {
    nextTick(() => {
      const scrollContainer = logContainer.value!;
      scrollContainer.scrollTop = scrollContainer.scrollHeight;
      // 更新滚动百分比
      scrollPercent.value = 100;
    });
  }
}


</script>

<template>
  <Page
      title="日志"
      description="应用日志"
      sticky
  >
    <div class="flex flex-col h-full md:h-auto md:min-h-[600px]"
         style="height: calc(100vh - 200px); min-height: 500px;">
      <!-- 控制栏 -->
      <div
          class="flex flex-col sm:flex-row items-start sm:items-center justify-between p-3 md:p-4 border-b border-gray-700 bg-gray-900 flex-shrink-0 control-bar gap-3 sm:gap-0">
        <div class="flex flex-wrap items-center gap-2 w-full sm:w-auto">
          <!-- 基础控制 -->
          <button
              @click="clearLogs"
              class="px-4 py-2 text-sm bg-red-600 hover:bg-red-700 text-white rounded transition-colors flex items-center gap-2 min-w-[80px] sm:min-w-0 flex-shrink-0 justify-center"
              title="清空所有日志"
          >
            <Trash2 :size="14"/>
            <span class="hidden xs:inline">清空</span>
          </button>

          <!-- 滚动控制 -->
          <div class="flex items-center gap-1 border-l border-gray-600 pl-2">
            <button
                @click="scrollToTop"
                class="px-4 py-2 text-sm bg-blue-600 hover:bg-blue-700 text-white rounded transition-colors flex items-center gap-2 min-w-[80px] sm:min-w-0 flex-shrink-0 justify-center"

                title="滚动到顶部"
            >
              <ArrowUp :size="14"/>
              <span class="hidden xs:inline">顶部</span>

            </button>
            <button
                @click="scrollToBottom"
                class="px-4 py-2 text-sm bg-blue-600 hover:bg-blue-700 text-white rounded transition-colors flex items-center gap-2 min-w-[80px] sm:min-w-0 flex-shrink-0 justify-center"
                title="滚动到底部"
            >
              <ArrowDown :size="14"/>
              <span class="hidden xs:inline">底部</span>

            </button>
            <button
                @click="toggleAutoScroll"
                :class="[
                'px-3 py-2 text-sm rounded transition-colors flex items-center gap-2 min-w-[80px] sm:min-w-[90px] flex-shrink-0 justify-center',
                isAutoScroll 
                  ? 'bg-green-600 hover:bg-green-700 text-white' 
                  : 'bg-gray-600 hover:bg-gray-700 text-white'
              ]"
                :title="isAutoScroll ? '点击关闭自动滚动' : '点击开启自动滚动'"
            >
              <RotateCcw v-if="isAutoScroll" :size="14" class="animate-spin"/>
              <Pause v-else :size="14"/>
              <span class="hidden sm:inline">{{ isAutoScroll ? '自动' : '手动' }}</span>
            </button>
          </div>
        </div>

        <div
            class="flex flex-col sm:flex-row items-start sm:items-center gap-2 sm:gap-4 text-xs sm:text-sm text-gray-400 w-full sm:w-auto">
          <span class="flex items-center gap-1">
            <span class="w-2 h-2 bg-blue-400 rounded-full animate-pulse"></span>
            <span class="whitespace-nowrap">{{ logs?.length }} 条日志</span>
          </span>
          <span :class="[
            'flex items-center gap-1',
            isAutoScroll ? 'text-green-400' : 'text-yellow-400'
          ]">
            <RotateCcw v-if="isAutoScroll" :size="12" class="animate-spin"/>
            <Pause v-else :size="12"/>
            <span class="whitespace-nowrap">{{ isAutoScroll ? '自动滚动' : '手动模式' }}</span>
          </span>
        </div>
      </div>

      <!-- 日志控制台 -->
      <div
          class="flex-1 overflow-hidden bg-black text-green-400 font-mono text-xs sm:text-sm log-container relative"
          style="
          font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
          line-height: 1.4;
        "
      >
        <div
            ref="logContainer"
            @scroll="handleScroll"
            class="h-full overflow-auto p-2 sm:p-4 space-y-1 scroll-smooth"
            style="
            scrollbar-width: thin;
            scrollbar-color: #4a5568 #1a202c;
          "
        >
          <div
              v-for="(log, index) in logs"
              :key="index"
              class="log-entry-group"
          >
            <!-- 日期分隔符 -->
            <div v-if="shouldShowDateSeparator(log, logs[index - 1])" class="date-separator">
              <div class="flex items-center my-3">
                <div class="flex-1 h-px bg-gray-600"></div>
                <span class="px-4 text-xs text-gray-300 bg-black font-medium">
                  {{ getDateLabel(log.time) }}
                </span>
                <div class="flex-1 h-px bg-gray-600"></div>
              </div>
            </div>

            <!-- 主日志行 -->
            <div class="flex items-start space-x-1 sm:space-x-2 py-1 px-1 sm:px-2 rounded log-entry">
              <!-- 时间戳 -->
              <span class="text-gray-500 text-xs shrink-0 w-20 sm:w-24 overflow-hidden" :title="log.time">
              {{ formatTime(log.time) }}
            </span>

              <!-- 日志级别 -->
              <span
                  :class="[
                'font-bold text-xs uppercase shrink-0 w-12 sm:w-16 overflow-hidden',
                getLogLevelColor(log.logLevel)
              ]"
              >
              [{{ (log.logLevel || 'INFO').slice(0, 4) }}]
            </span>

              <!-- 消息内容 -->
              <span class="text-gray-300 flex-1 break-words break-all">
              {{ log.message }}
            </span>
            </div>

            <!-- 错误信息和堆栈跟踪（紧跟ERROR日志） -->
            <div
                v-if="(log.error || log.stackTrace) && (log.logLevel?.toLowerCase() === 'error' || log.logLevel?.toLowerCase() === 'fatal')"
                class="flex items-start space-x-2 py-1 px-2">
              <!-- 空白区域（与时间戳对齐） -->
              <span class="text-transparent text-xs shrink-0 w-20"> </span>

              <!-- 空白区域（与日志级别对齐） -->
              <span class="text-transparent font-bold text-xs uppercase shrink-0 w-16"> </span>

              <!-- 错误信息内容区域 -->
              <div class="flex-1">
                <div v-if="log.error" class="text-red-400 text-xs">
                  ❌ Error: {{ log.error }}
                </div>
                <div v-if="log.stackTrace" class="text-red-300 text-xs mt-1 whitespace-pre-wrap font-mono">
                  <div>📍 Stack Trace:</div>
                  <div>
                    {{ log.stackTrace }}
                  </div>
                </div>
              </div>
            </div>

            <!-- 示例信息（紧跟对应日志） -->
            <div v-if="log.example" class="flex items-start space-x-2 py-1 px-2">
              <!-- 空白区域（与时间戳对齐） -->
              <span class="text-transparent text-xs shrink-0 w-20"> </span>

              <!-- 空白区域（与日志级别对齐） -->
              <span class="text-transparent font-bold text-xs uppercase shrink-0 w-16"> </span>

              <!-- 示例信息内容区域 -->
              <div class="flex-1 text-yellow-300 text-xs">
                💡 Example: {{ log.example }}
              </div>
            </div>
          </div>

          <!-- 滚动位置指示器 -->
          <div
              v-if="logs.length > 0"
              class="scroll-indicator"
          >
            {{ scrollPercent }}%
          </div>

          <!-- 空状态 -->
          <div v-if="logs.length === 0" class="text-center py-8 text-gray-500">
            <div class="text-lg mb-2">📝</div>
            <div class="text-sm sm:text-base">暂无日志数据</div>
            <div class="text-xs mt-1">WebSocket 连接状态: {{ socket ? '已连接' : '未连接' }}</div>
            <!--            <div class="text-xs mt-1 text-gray-600">连接地址: {{ socket?.url || '未知' }}</div>-->
          </div>
        </div>
      </div>
    </div>
  </Page>
</template>

<style scoped>
/* 日期分隔符样式 */
.date-separator {
  margin: 8px 0;
}

.date-separator span {
  background: linear-gradient(90deg, transparent, rgba(0, 0, 0, 0.8), transparent);
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 11px;
  letter-spacing: 0.5px;
  text-transform: uppercase;
  font-weight: 600;
}

/* 移动端专用样式 */
@media (max-width: 640px) {
  .log-container > div::-webkit-scrollbar {
    width: 8px;
  }

  /* 移动端字体大小调整 */
  .log-entry {
    font-size: 12px;
  }

  /* 移动端按钮触摸优化 */
  button {
    min-height: 44px;
    touch-action: manipulation;
    font-weight: 500;
  }

  /* 移动端按钮组优化 */
  .control-bar .flex.items-center.gap-1 {
    gap: 0.5rem;
  }

  /* 移动端滚动指示器位置调整 */
  .scroll-indicator {
    right: 8px;
    bottom: 8px;
    padding: 3px 6px;
    font-size: 10px;
  }
}

/* 超小屏幕优化 */
@media (max-width: 480px) {
  .control-bar {
    padding: 12px;
  }

  .log-container > div {
    padding: 8px;
  }

  /* 超小屏幕按钮进一步优化 */
  button {
    min-width: 48px;
    font-size: 13px;
  }

  /* 调整按钮间距 */
  .control-bar .flex.items-center.gap-2 {
    gap: 0.75rem;
  }
}

/* 触摸设备优化 */
@media (hover: none) {
  button:hover {
    transform: none;
    box-shadow: none;
  }

  .log-entry:hover {
    transform: none;
  }
}

/* 自定义滚动条样式 */
.log-container > div::-webkit-scrollbar {
  width: 12px;
}

.log-container > div::-webkit-scrollbar-track {
  background: #1a202c;
  border-radius: 6px;
}

.log-container > div::-webkit-scrollbar-thumb {
  background: #4a5568;
  border-radius: 6px;
  border: 2px solid #1a202c;
}

.log-container > div::-webkit-scrollbar-thumb:hover {
  background: #718096;
}

/* 平滑滚动 */
.log-container > div {
  scroll-behavior: smooth;
}

/* 日志条目组的样式 */
.log-entry-group {
  margin-bottom: 4px;
}

.log-entry-group:last-child {
  margin-bottom: 0;
}

/* 日志行的过渡效果 */
.log-entry {
  transition: all 0.2s ease;
}

.log-entry:hover {
  background-color: rgba(45, 55, 72, 0.5) !important;
  transform: translateX(2px);
}

/* 按钮悬停效果 */
button {
  transition: all 0.2s ease;
}

button:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

button:active {
  transform: translateY(0);
}

/* 旋转动画 */
@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

.animate-spin {
  animation: spin 1s linear infinite;
}

/* 滚动指示器 */
.scroll-indicator {
  position: absolute;
  right: 16px;
  bottom: 16px;
  background: rgba(0, 0, 0, 0.8);
  color: #a0aec0;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  pointer-events: none;
  z-index: 10;
  backdrop-filter: blur(4px);
  border: 1px solid rgba(74, 85, 104, 0.3);
}

/* 状态指示器圆点脉冲动画 */
@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

.animate-pulse {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

/* 确保容器不会超出视口 */
.log-container {
  max-height: 100%;
  overflow: hidden;
}

/* 控制栏样式增强 */
.control-bar {
  backdrop-filter: blur(8px);
  border-bottom: 1px solid rgba(55, 65, 81, 0.3);
}

/* 响应式断字 */
.break-words {
  overflow-wrap: break-word;
  word-wrap: break-word;
  word-break: break-word;
  hyphens: auto;
}

.break-all {
  word-break: break-all;
}

/* 自定义断点 xs */
@media (min-width: 475px) {
  .xs\:inline {
    display: inline;
  }
}
</style>