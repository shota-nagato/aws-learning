import {
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Box,
  Skeleton,
  Toolbar,
  Button,
} from "@mui/material";
import AddCircleOutlineIcon from "@mui/icons-material/AddCircleOutline";

import { useTaskListQuery } from "@/hooks/useTask";
import { formatDate } from "@/utils/date";
import TaskStatusChip from "../chip/TaskStatusChip";
import { useModal } from "@/hooks/useModal";
import CreateTaskModal from "../modal/CreateTaskModal";
import { useDetailModal } from "@/hooks/useDetailModal";
import DetailTaskModal from "../modal/DetailTaskModal";

const TaskListPage = () => {
  const { data: tasks, isLoading } = useTaskListQuery();
  const createModal = useModal();
  const detailModal = useDetailModal();

  const renderSkeletonRows = () =>
    Array.from({ length: 5 }).map((_, index) => (
      <TableRow key={index}>
        {[...Array(5)].map((__, i) => (
          <TableCell key={i}>
            <Skeleton variant="text" />
          </TableCell>
        ))}
      </TableRow>
    ));

  return (
    <Box>
      <Toolbar variant="dense">
        <Box sx={{ ml: "auto" }}>
            <Button
              startIcon={<AddCircleOutlineIcon />}
              size="small"
              variant="contained"
              onClick={() => {
                createModal.onOpen();
              }}
            >
              新規作成
            </Button>
        </Box>
      </Toolbar>
      <TableContainer component={Paper}>
        <Table aria-label="タスク一覧テーブル">
          <TableHead>
            <TableRow>
              <TableCell>タイトル</TableCell>
              <TableCell>ステータス</TableCell>
              <TableCell>期限</TableCell>
              <TableCell>作成日</TableCell>
              <TableCell>更新日</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {isLoading && renderSkeletonRows()}
            {!isLoading &&
              tasks?.map((task) => (
                <TableRow
                  key={task.id}
                  onClick={() => {
                    detailModal.onOpen(task.id);
                  }}
                >
                  <TableCell>{task.title}</TableCell>
                  <TableCell>
                    <TaskStatusChip status={task.status} />
                  </TableCell>
                  <TableCell>
                    {task.dueDate ? formatDate(task.dueDate) : "-"}
                  </TableCell>
                  <TableCell>{formatDate(task.createdAt)}</TableCell>
                  <TableCell>{formatDate(task.updatedAt)}</TableCell>
                </TableRow>
              ))}
          </TableBody>
        </Table>
      </TableContainer>
      <CreateTaskModal
        isOpen={createModal.isOpen}
        onClose={createModal.onClose}
      />
      {detailModal.taskId && (
        <DetailTaskModal
          isOpen={detailModal.isOpen}
          onClose={detailModal.onClose}
          taskId={detailModal.taskId}
        />
      )}
    </Box>
  );
};

export default TaskListPage;
