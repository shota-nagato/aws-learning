import { apiV1Client } from "@/libs/apiClient";
import type { ApiResponse } from "@/types/response";
import {
  type TaskDetail,
  type TaskDetailResponse,
  type TaskList,
  type TaskListResponse,
} from "@/types/task";

/**
 * タスク一覧取得リクエスト送信
 */
export const getTaskList = async (): Promise<TaskList> => {
  const res = await apiV1Client.get<ApiResponse<TaskListResponse>>(
    "/tasks",
    {}
  );
  const data = res.data.data;

  if (!data) {
    throw new Error(`不正なレスポンス: ${JSON.stringify(res.data)}`);
  }

  return data;
};

type CreateParams = {
  title: string;
  description?: string;
  status: string;
  dueDate?: Date;
};

export const createTask = async (input: CreateParams): Promise<TaskDetail> => {
  const res = await apiV1Client.post<ApiResponse<TaskDetailResponse>>(
    "/tasks",
    {
      data: {
        ...input,
      },
    }
  );
  return res.data.data;
};

type UpdateParams = {
  taskId: string;
  title?: string;
  description?: string;
  status?: string;
  dueDate?: Date;
};

/**
 * タスク更新リクエストを送信
 */
export const updateTask = async (input: UpdateParams) => {
  const { taskId, ...rest } = input;
  const res = await apiV1Client.patch<ApiResponse<TaskDetailResponse>>(
    `/tasks/${taskId}`,
    {
      data: {
        ...rest,
      },
    }
  );
  return res.data.data;
};

export const deleteTask = async (taskId: string) => {
  await apiV1Client.delete<ApiResponse<null>>(`/tasks/${taskId}`);
  return;
};
