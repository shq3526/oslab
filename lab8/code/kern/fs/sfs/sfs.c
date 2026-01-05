#include <defs.h>
#include <sfs.h>
#include <error.h>
#include <assert.h>

/*
 * sfs_init - mount sfs on disk0
 * SFS 文件系统初始化函数。
 * * CALL GRAPH:
 * kern_init --> fs_init --> sfs_init
 * * 作用：
 * 在系统启动时，尝试将名为 "disk0" 的设备挂载为 SFS 文件系统。
 * "disk0" 设备已经在 dev_init 中被初始化并注册到了 VFS 的设备列表中。
 */
void
sfs_init(void) {
    int ret;
    // 调用 sfs_mount 将 disk0 挂载
    // sfs_mount 内部会调用 vfs_mount，最终调用 sfs_do_mount 进行超级块读取和校验
    if ((ret = sfs_mount("disk0")) != 0) {
        // 如果挂载失败（例如磁盘未格式化、损坏或设备不存在），内核 panic 停止运行
        // 因为这是根文件系统，如果它挂载失败，系统无法继续运行
        panic("failed: sfs: sfs_mount: %e.\n", ret);
    }
}