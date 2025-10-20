#ifndef __KERN_MM_BUDDY_SYSTEM_PMM_H__
#define __KERN_MM_BUDDY_SYSTEM_PMM_H__

#include <pmm.h>

struct buddy2;
struct buddy2* buddy2_new( int size );
void buddy2_destroy( struct buddy2* self );

int buddy2_alloc(struct buddy2* self, int size);
void buddy2_free(struct buddy2* self, int offset);

int buddy2_size(struct buddy2* self, int offset);
void buddy2_dump(struct buddy2* self);

extern const struct pmm_manager buddy_system_pmm_manager;

#endif /* ! __KERN_MM_BUDDY_SYSTEM_PMM_H__ */