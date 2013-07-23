/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x7708f090 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "C:/Users/jvoigts/Documents/GitHub/rhythm/LED_controller.v";
static unsigned int ng1[] = {0U, 0U};
static int ng2[] = {0, 0};
static unsigned int ng3[] = {1U, 0U};
static int ng4[] = {35, 0};
static int ng5[] = {70, 0};
static int ng6[] = {125, 0};
static int ng7[] = {1, 0};
static int ng8[] = {23, 0};
static int ng9[] = {2, 0};
static int ng10[] = {3, 0};
static int ng11[] = {4, 0};
static int ng12[] = {5, 0};
static int ng13[] = {6, 0};
static int ng14[] = {7, 0};
static int ng15[] = {8, 0};
static int ng16[] = {9, 0};



static void Always_56_0(char *t0)
{
    char t13[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    unsigned int t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    char *t11;
    char *t12;
    char *t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    char *t23;
    unsigned int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    unsigned int t28;
    char *t29;
    char *t30;
    char *t31;
    char *t32;
    int t33;
    char *t34;
    char *t35;

LAB0:    t1 = (t0 + 5176U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(56, ng0);
    t2 = (t0 + 5992);
    *((int *)t2) = 1;
    t3 = (t0 + 5208);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(56, ng0);

LAB5:    xsi_set_current_line(57, ng0);
    t4 = (t0 + 1456U);
    t5 = *((char **)t4);
    t4 = (t5 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (~(t6));
    t8 = *((unsigned int *)t5);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB6;

LAB7:    xsi_set_current_line(62, ng0);

LAB10:    xsi_set_current_line(64, ng0);
    t2 = (t0 + 4096);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = (t4 + 4);
    t6 = *((unsigned int *)t5);
    t7 = (~(t6));
    t8 = *((unsigned int *)t4);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB11;

LAB12:    xsi_set_current_line(66, ng0);

LAB15:    xsi_set_current_line(68, ng0);
    t2 = (t0 + 3936);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t13, 0, 8);
    t5 = (t4 + 4);
    t6 = *((unsigned int *)t5);
    t7 = (~(t6));
    t8 = *((unsigned int *)t4);
    t9 = (t8 & t7);
    t10 = (t9 & 1U);
    if (t10 != 0)
        goto LAB19;

LAB17:    if (*((unsigned int *)t5) == 0)
        goto LAB16;

LAB18:    t11 = (t13 + 4);
    *((unsigned int *)t13) = 1;
    *((unsigned int *)t11) = 1;

LAB19:    t12 = (t13 + 4);
    t14 = (t4 + 4);
    t15 = *((unsigned int *)t4);
    t16 = (~(t15));
    *((unsigned int *)t13) = t16;
    *((unsigned int *)t12) = 0;
    if (*((unsigned int *)t14) != 0)
        goto LAB21;

LAB20:    t21 = *((unsigned int *)t13);
    *((unsigned int *)t13) = (t21 & 1U);
    t22 = *((unsigned int *)t12);
    *((unsigned int *)t12) = (t22 & 1U);
    t23 = (t13 + 4);
    t24 = *((unsigned int *)t23);
    t25 = (~(t24));
    t26 = *((unsigned int *)t13);
    t27 = (t26 & t25);
    t28 = (t27 != 0);
    if (t28 > 0)
        goto LAB22;

LAB23:    xsi_set_current_line(81, ng0);

LAB34:    xsi_set_current_line(83, ng0);
    t2 = (t0 + 3456);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);

LAB35:    t5 = ((char*)((ng2)));
    t33 = xsi_vlog_unsigned_case_compare(t4, 16, t5, 32);
    if (t33 == 1)
        goto LAB36;

LAB37:    t2 = ((char*)((ng5)));
    t33 = xsi_vlog_unsigned_case_compare(t4, 16, t2, 32);
    if (t33 == 1)
        goto LAB38;

LAB39:
LAB40:
LAB24:
LAB13:    xsi_set_current_line(97, ng0);
    t2 = (t0 + 3456);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t11 = ((char*)((ng6)));
    memset(t13, 0, 8);
    t12 = (t5 + 4);
    t14 = (t11 + 4);
    t6 = *((unsigned int *)t5);
    t7 = *((unsigned int *)t11);
    t8 = (t6 ^ t7);
    t9 = *((unsigned int *)t12);
    t10 = *((unsigned int *)t14);
    t15 = (t9 ^ t10);
    t16 = (t8 | t15);
    t17 = *((unsigned int *)t12);
    t18 = *((unsigned int *)t14);
    t19 = (t17 | t18);
    t20 = (~(t19));
    t21 = (t16 & t20);
    if (t21 != 0)
        goto LAB46;

LAB43:    if (t19 != 0)
        goto LAB45;

LAB44:    *((unsigned int *)t13) = 1;

LAB46:    t29 = (t13 + 4);
    t22 = *((unsigned int *)t29);
    t24 = (~(t22));
    t25 = *((unsigned int *)t13);
    t26 = (t25 & t24);
    t27 = (t26 != 0);
    if (t27 > 0)
        goto LAB47;

LAB48:    xsi_set_current_line(100, ng0);
    t2 = (t0 + 3456);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t11 = ((char*)((ng7)));
    memset(t13, 0, 8);
    xsi_vlog_unsigned_add(t13, 32, t5, 16, t11, 32);
    t12 = (t0 + 3456);
    xsi_vlogvar_wait_assign_value(t12, t13, 0, 0, 16, 0LL);

LAB49:
LAB8:    goto LAB2;

LAB6:    xsi_set_current_line(57, ng0);

LAB9:    xsi_set_current_line(58, ng0);
    t11 = ((char*)((ng1)));
    t12 = (t0 + 3456);
    xsi_vlogvar_wait_assign_value(t12, t11, 0, 0, 16, 0LL);
    xsi_set_current_line(60, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 3296);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    goto LAB8;

LAB11:    xsi_set_current_line(64, ng0);

LAB14:    xsi_set_current_line(65, ng0);
    t11 = ((char*)((ng1)));
    t12 = (t0 + 3296);
    xsi_vlogvar_wait_assign_value(t12, t11, 0, 0, 1, 0LL);
    goto LAB13;

LAB16:    *((unsigned int *)t13) = 1;
    goto LAB19;

LAB21:    t17 = *((unsigned int *)t13);
    t18 = *((unsigned int *)t14);
    *((unsigned int *)t13) = (t17 | t18);
    t19 = *((unsigned int *)t12);
    t20 = *((unsigned int *)t14);
    *((unsigned int *)t12) = (t19 | t20);
    goto LAB20;

LAB22:    xsi_set_current_line(68, ng0);

LAB25:    xsi_set_current_line(70, ng0);
    t29 = (t0 + 3456);
    t30 = (t29 + 56U);
    t31 = *((char **)t30);

LAB26:    t32 = ((char*)((ng2)));
    t33 = xsi_vlog_unsigned_case_compare(t31, 16, t32, 32);
    if (t33 == 1)
        goto LAB27;

LAB28:    t2 = ((char*)((ng4)));
    t33 = xsi_vlog_unsigned_case_compare(t31, 16, t2, 32);
    if (t33 == 1)
        goto LAB29;

LAB30:
LAB31:    goto LAB24;

LAB27:    xsi_set_current_line(71, ng0);

LAB32:    xsi_set_current_line(72, ng0);
    t34 = ((char*)((ng3)));
    t35 = (t0 + 3296);
    xsi_vlogvar_wait_assign_value(t35, t34, 0, 0, 1, 0LL);
    goto LAB31;

LAB29:    xsi_set_current_line(75, ng0);

LAB33:    xsi_set_current_line(76, ng0);
    t3 = ((char*)((ng1)));
    t4 = (t0 + 3296);
    xsi_vlogvar_wait_assign_value(t4, t3, 0, 0, 1, 0LL);
    goto LAB31;

LAB36:    xsi_set_current_line(84, ng0);

LAB41:    xsi_set_current_line(85, ng0);
    t11 = ((char*)((ng3)));
    t12 = (t0 + 3296);
    xsi_vlogvar_wait_assign_value(t12, t11, 0, 0, 1, 0LL);
    goto LAB40;

LAB38:    xsi_set_current_line(88, ng0);

LAB42:    xsi_set_current_line(89, ng0);
    t3 = ((char*)((ng1)));
    t5 = (t0 + 3296);
    xsi_vlogvar_wait_assign_value(t5, t3, 0, 0, 1, 0LL);
    goto LAB40;

LAB45:    t23 = (t13 + 4);
    *((unsigned int *)t13) = 1;
    *((unsigned int *)t23) = 1;
    goto LAB46;

LAB47:    xsi_set_current_line(98, ng0);
    t30 = ((char*)((ng2)));
    t32 = (t0 + 3456);
    xsi_vlogvar_wait_assign_value(t32, t30, 0, 0, 16, 0LL);
    goto LAB49;

}

static void Always_105_1(char *t0)
{
    char t13[8];
    char t31[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    unsigned int t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    char *t11;
    char *t12;
    unsigned int t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    char *t21;
    char *t22;
    unsigned int t23;
    unsigned int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    char *t28;
    char *t29;
    char *t30;
    char *t32;
    char *t33;
    char *t34;
    char *t35;
    char *t36;
    char *t37;
    char *t38;

LAB0:    t1 = (t0 + 5424U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(105, ng0);
    t2 = (t0 + 6008);
    *((int *)t2) = 1;
    t3 = (t0 + 5456);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(105, ng0);

LAB5:    xsi_set_current_line(106, ng0);
    t4 = (t0 + 1456U);
    t5 = *((char **)t4);
    t4 = (t5 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (~(t6));
    t8 = *((unsigned int *)t5);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB6;

LAB7:    xsi_set_current_line(108, ng0);

LAB10:    xsi_set_current_line(109, ng0);
    t2 = (t0 + 3456);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = ((char*)((ng7)));
    memset(t13, 0, 8);
    t11 = (t4 + 4);
    t12 = (t5 + 4);
    t6 = *((unsigned int *)t4);
    t7 = *((unsigned int *)t5);
    t8 = (t6 ^ t7);
    t9 = *((unsigned int *)t11);
    t10 = *((unsigned int *)t12);
    t14 = (t9 ^ t10);
    t15 = (t8 | t14);
    t16 = *((unsigned int *)t11);
    t17 = *((unsigned int *)t12);
    t18 = (t16 | t17);
    t19 = (~(t18));
    t20 = (t15 & t19);
    if (t20 != 0)
        goto LAB14;

LAB11:    if (t18 != 0)
        goto LAB13;

LAB12:    *((unsigned int *)t13) = 1;

LAB14:    t22 = (t13 + 4);
    t23 = *((unsigned int *)t22);
    t24 = (~(t23));
    t25 = *((unsigned int *)t13);
    t26 = (t25 & t24);
    t27 = (t26 != 0);
    if (t27 > 0)
        goto LAB15;

LAB16:
LAB17:
LAB8:    goto LAB2;

LAB6:    xsi_set_current_line(106, ng0);

LAB9:    xsi_set_current_line(107, ng0);
    t11 = ((char*)((ng1)));
    t12 = (t0 + 3776);
    xsi_vlogvar_wait_assign_value(t12, t11, 0, 0, 5, 0LL);
    goto LAB8;

LAB13:    t21 = (t13 + 4);
    *((unsigned int *)t13) = 1;
    *((unsigned int *)t21) = 1;
    goto LAB14;

LAB15:    xsi_set_current_line(109, ng0);

LAB18:    xsi_set_current_line(111, ng0);
    t28 = (t0 + 4256);
    t29 = (t28 + 56U);
    t30 = *((char **)t29);
    t32 = (t0 + 4256);
    t33 = (t32 + 72U);
    t34 = *((char **)t33);
    t35 = (t0 + 3776);
    t36 = (t35 + 56U);
    t37 = *((char **)t36);
    xsi_vlog_generic_get_index_select_value(t31, 1, t30, t34, 2, t37, 5, 2);
    t38 = (t0 + 3936);
    xsi_vlogvar_wait_assign_value(t38, t31, 0, 0, 1, 0LL);
    xsi_set_current_line(113, ng0);
    t2 = (t0 + 3776);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = ((char*)((ng7)));
    memset(t13, 0, 8);
    xsi_vlog_unsigned_add(t13, 32, t4, 5, t5, 32);
    t11 = (t0 + 3776);
    xsi_vlogvar_wait_assign_value(t11, t13, 0, 0, 5, 0LL);
    xsi_set_current_line(115, ng0);
    t2 = (t0 + 3776);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = ((char*)((ng8)));
    memset(t13, 0, 8);
    t11 = (t4 + 4);
    t12 = (t5 + 4);
    t6 = *((unsigned int *)t4);
    t7 = *((unsigned int *)t5);
    t8 = (t6 ^ t7);
    t9 = *((unsigned int *)t11);
    t10 = *((unsigned int *)t12);
    t14 = (t9 ^ t10);
    t15 = (t8 | t14);
    t16 = *((unsigned int *)t11);
    t17 = *((unsigned int *)t12);
    t18 = (t16 | t17);
    t19 = (~(t18));
    t20 = (t15 & t19);
    if (t20 != 0)
        goto LAB22;

LAB19:    if (t18 != 0)
        goto LAB21;

LAB20:    *((unsigned int *)t13) = 1;

LAB22:    t22 = (t13 + 4);
    t23 = *((unsigned int *)t22);
    t24 = (~(t23));
    t25 = *((unsigned int *)t13);
    t26 = (t25 & t24);
    t27 = (t26 != 0);
    if (t27 > 0)
        goto LAB23;

LAB24:
LAB25:    goto LAB17;

LAB21:    t21 = (t13 + 4);
    *((unsigned int *)t13) = 1;
    *((unsigned int *)t21) = 1;
    goto LAB22;

LAB23:    xsi_set_current_line(116, ng0);
    t28 = ((char*)((ng2)));
    t29 = (t0 + 3776);
    xsi_vlogvar_wait_assign_value(t29, t28, 0, 0, 5, 0LL);
    goto LAB25;

}

static void Always_122_2(char *t0)
{
    char t13[8];
    char t22[8];
    char t38[8];
    char t54[8];
    char t62[8];
    char t104[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    unsigned int t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    char *t11;
    char *t12;
    unsigned int t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    char *t21;
    char *t23;
    unsigned int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    unsigned int t28;
    char *t29;
    char *t30;
    unsigned int t31;
    unsigned int t32;
    unsigned int t33;
    char *t34;
    char *t35;
    char *t36;
    char *t37;
    char *t39;
    char *t40;
    unsigned int t41;
    unsigned int t42;
    unsigned int t43;
    unsigned int t44;
    unsigned int t45;
    unsigned int t46;
    unsigned int t47;
    unsigned int t48;
    unsigned int t49;
    unsigned int t50;
    unsigned int t51;
    unsigned int t52;
    char *t53;
    char *t55;
    unsigned int t56;
    unsigned int t57;
    unsigned int t58;
    unsigned int t59;
    unsigned int t60;
    char *t61;
    unsigned int t63;
    unsigned int t64;
    unsigned int t65;
    char *t66;
    char *t67;
    char *t68;
    unsigned int t69;
    unsigned int t70;
    unsigned int t71;
    unsigned int t72;
    unsigned int t73;
    unsigned int t74;
    unsigned int t75;
    char *t76;
    char *t77;
    unsigned int t78;
    unsigned int t79;
    unsigned int t80;
    unsigned int t81;
    unsigned int t82;
    unsigned int t83;
    unsigned int t84;
    unsigned int t85;
    int t86;
    int t87;
    unsigned int t88;
    unsigned int t89;
    unsigned int t90;
    unsigned int t91;
    unsigned int t92;
    unsigned int t93;
    char *t94;
    unsigned int t95;
    unsigned int t96;
    unsigned int t97;
    unsigned int t98;
    unsigned int t99;
    char *t100;
    char *t101;
    char *t102;
    char *t103;
    char *t105;

LAB0:    t1 = (t0 + 5672U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(122, ng0);
    t2 = (t0 + 6024);
    *((int *)t2) = 1;
    t3 = (t0 + 5704);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(122, ng0);

LAB5:    xsi_set_current_line(123, ng0);
    t4 = (t0 + 1456U);
    t5 = *((char **)t4);
    t4 = (t5 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (~(t6));
    t8 = *((unsigned int *)t5);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB6;

LAB7:    xsi_set_current_line(125, ng0);

LAB10:    xsi_set_current_line(127, ng0);
    t2 = (t0 + 3776);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = ((char*)((ng8)));
    memset(t13, 0, 8);
    t11 = (t4 + 4);
    t12 = (t5 + 4);
    t6 = *((unsigned int *)t4);
    t7 = *((unsigned int *)t5);
    t8 = (t6 ^ t7);
    t9 = *((unsigned int *)t11);
    t10 = *((unsigned int *)t12);
    t14 = (t9 ^ t10);
    t15 = (t8 | t14);
    t16 = *((unsigned int *)t11);
    t17 = *((unsigned int *)t12);
    t18 = (t16 | t17);
    t19 = (~(t18));
    t20 = (t15 & t19);
    if (t20 != 0)
        goto LAB14;

LAB11:    if (t18 != 0)
        goto LAB13;

LAB12:    *((unsigned int *)t13) = 1;

LAB14:    memset(t22, 0, 8);
    t23 = (t13 + 4);
    t24 = *((unsigned int *)t23);
    t25 = (~(t24));
    t26 = *((unsigned int *)t13);
    t27 = (t26 & t25);
    t28 = (t27 & 1U);
    if (t28 != 0)
        goto LAB15;

LAB16:    if (*((unsigned int *)t23) != 0)
        goto LAB17;

LAB18:    t30 = (t22 + 4);
    t31 = *((unsigned int *)t22);
    t32 = *((unsigned int *)t30);
    t33 = (t31 || t32);
    if (t33 > 0)
        goto LAB19;

LAB20:    memcpy(t62, t22, 8);

LAB21:    t94 = (t62 + 4);
    t95 = *((unsigned int *)t94);
    t96 = (~(t95));
    t97 = *((unsigned int *)t62);
    t98 = (t97 & t96);
    t99 = (t98 != 0);
    if (t99 > 0)
        goto LAB33;

LAB34:
LAB35:
LAB8:    goto LAB2;

LAB6:    xsi_set_current_line(123, ng0);

LAB9:    xsi_set_current_line(124, ng0);
    t11 = ((char*)((ng1)));
    t12 = (t0 + 3616);
    xsi_vlogvar_wait_assign_value(t12, t11, 0, 0, 16, 0LL);
    goto LAB8;

LAB13:    t21 = (t13 + 4);
    *((unsigned int *)t13) = 1;
    *((unsigned int *)t21) = 1;
    goto LAB14;

LAB15:    *((unsigned int *)t22) = 1;
    goto LAB18;

LAB17:    t29 = (t22 + 4);
    *((unsigned int *)t22) = 1;
    *((unsigned int *)t29) = 1;
    goto LAB18;

LAB19:    t34 = (t0 + 3456);
    t35 = (t34 + 56U);
    t36 = *((char **)t35);
    t37 = ((char*)((ng2)));
    memset(t38, 0, 8);
    t39 = (t36 + 4);
    t40 = (t37 + 4);
    t41 = *((unsigned int *)t36);
    t42 = *((unsigned int *)t37);
    t43 = (t41 ^ t42);
    t44 = *((unsigned int *)t39);
    t45 = *((unsigned int *)t40);
    t46 = (t44 ^ t45);
    t47 = (t43 | t46);
    t48 = *((unsigned int *)t39);
    t49 = *((unsigned int *)t40);
    t50 = (t48 | t49);
    t51 = (~(t50));
    t52 = (t47 & t51);
    if (t52 != 0)
        goto LAB25;

LAB22:    if (t50 != 0)
        goto LAB24;

LAB23:    *((unsigned int *)t38) = 1;

LAB25:    memset(t54, 0, 8);
    t55 = (t38 + 4);
    t56 = *((unsigned int *)t55);
    t57 = (~(t56));
    t58 = *((unsigned int *)t38);
    t59 = (t58 & t57);
    t60 = (t59 & 1U);
    if (t60 != 0)
        goto LAB26;

LAB27:    if (*((unsigned int *)t55) != 0)
        goto LAB28;

LAB29:    t63 = *((unsigned int *)t22);
    t64 = *((unsigned int *)t54);
    t65 = (t63 & t64);
    *((unsigned int *)t62) = t65;
    t66 = (t22 + 4);
    t67 = (t54 + 4);
    t68 = (t62 + 4);
    t69 = *((unsigned int *)t66);
    t70 = *((unsigned int *)t67);
    t71 = (t69 | t70);
    *((unsigned int *)t68) = t71;
    t72 = *((unsigned int *)t68);
    t73 = (t72 != 0);
    if (t73 == 1)
        goto LAB30;

LAB31:
LAB32:    goto LAB21;

LAB24:    t53 = (t38 + 4);
    *((unsigned int *)t38) = 1;
    *((unsigned int *)t53) = 1;
    goto LAB25;

LAB26:    *((unsigned int *)t54) = 1;
    goto LAB29;

LAB28:    t61 = (t54 + 4);
    *((unsigned int *)t54) = 1;
    *((unsigned int *)t61) = 1;
    goto LAB29;

LAB30:    t74 = *((unsigned int *)t62);
    t75 = *((unsigned int *)t68);
    *((unsigned int *)t62) = (t74 | t75);
    t76 = (t22 + 4);
    t77 = (t54 + 4);
    t78 = *((unsigned int *)t22);
    t79 = (~(t78));
    t80 = *((unsigned int *)t76);
    t81 = (~(t80));
    t82 = *((unsigned int *)t54);
    t83 = (~(t82));
    t84 = *((unsigned int *)t77);
    t85 = (~(t84));
    t86 = (t79 & t81);
    t87 = (t83 & t85);
    t88 = (~(t86));
    t89 = (~(t87));
    t90 = *((unsigned int *)t68);
    *((unsigned int *)t68) = (t90 & t88);
    t91 = *((unsigned int *)t68);
    *((unsigned int *)t68) = (t91 & t89);
    t92 = *((unsigned int *)t62);
    *((unsigned int *)t62) = (t92 & t88);
    t93 = *((unsigned int *)t62);
    *((unsigned int *)t62) = (t93 & t89);
    goto LAB32;

LAB33:    xsi_set_current_line(127, ng0);

LAB36:    xsi_set_current_line(130, ng0);
    t100 = (t0 + 3616);
    t101 = (t100 + 56U);
    t102 = *((char **)t101);
    t103 = ((char*)((ng7)));
    memset(t104, 0, 8);
    xsi_vlog_unsigned_add(t104, 32, t102, 16, t103, 32);
    t105 = (t0 + 3616);
    xsi_vlogvar_wait_assign_value(t105, t104, 0, 0, 16, 0LL);
    xsi_set_current_line(132, ng0);
    t2 = (t0 + 3616);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);

LAB37:    t5 = ((char*)((ng2)));
    t86 = xsi_vlog_unsigned_case_compare(t4, 16, t5, 32);
    if (t86 == 1)
        goto LAB38;

LAB39:    t2 = ((char*)((ng7)));
    t86 = xsi_vlog_unsigned_case_compare(t4, 16, t2, 32);
    if (t86 == 1)
        goto LAB40;

LAB41:    t2 = ((char*)((ng9)));
    t86 = xsi_vlog_unsigned_case_compare(t4, 16, t2, 32);
    if (t86 == 1)
        goto LAB42;

LAB43:    t2 = ((char*)((ng10)));
    t86 = xsi_vlog_unsigned_case_compare(t4, 16, t2, 32);
    if (t86 == 1)
        goto LAB44;

LAB45:    t2 = ((char*)((ng11)));
    t86 = xsi_vlog_unsigned_case_compare(t4, 16, t2, 32);
    if (t86 == 1)
        goto LAB46;

LAB47:    t2 = ((char*)((ng12)));
    t86 = xsi_vlog_unsigned_case_compare(t4, 16, t2, 32);
    if (t86 == 1)
        goto LAB48;

LAB49:    t2 = ((char*)((ng13)));
    t86 = xsi_vlog_unsigned_case_compare(t4, 16, t2, 32);
    if (t86 == 1)
        goto LAB50;

LAB51:    t2 = ((char*)((ng14)));
    t86 = xsi_vlog_unsigned_case_compare(t4, 16, t2, 32);
    if (t86 == 1)
        goto LAB52;

LAB53:    t2 = ((char*)((ng15)));
    t86 = xsi_vlog_unsigned_case_compare(t4, 16, t2, 32);
    if (t86 == 1)
        goto LAB54;

LAB55:    t2 = ((char*)((ng16)));
    t86 = xsi_vlog_unsigned_case_compare(t4, 16, t2, 32);
    if (t86 == 1)
        goto LAB56;

LAB57:
LAB58:    xsi_set_current_line(178, ng0);
    t2 = (t0 + 3616);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t11 = ((char*)((ng16)));
    memset(t13, 0, 8);
    t12 = (t5 + 4);
    t21 = (t11 + 4);
    t6 = *((unsigned int *)t5);
    t7 = *((unsigned int *)t11);
    t8 = (t6 ^ t7);
    t9 = *((unsigned int *)t12);
    t10 = *((unsigned int *)t21);
    t14 = (t9 ^ t10);
    t15 = (t8 | t14);
    t16 = *((unsigned int *)t12);
    t17 = *((unsigned int *)t21);
    t18 = (t16 | t17);
    t19 = (~(t18));
    t20 = (t15 & t19);
    if (t20 != 0)
        goto LAB72;

LAB69:    if (t18 != 0)
        goto LAB71;

LAB70:    *((unsigned int *)t13) = 1;

LAB72:    t29 = (t13 + 4);
    t24 = *((unsigned int *)t29);
    t25 = (~(t24));
    t26 = *((unsigned int *)t13);
    t27 = (t26 & t25);
    t28 = (t27 != 0);
    if (t28 > 0)
        goto LAB73;

LAB74:
LAB75:    goto LAB35;

LAB38:    xsi_set_current_line(133, ng0);

LAB59:    xsi_set_current_line(134, ng0);
    t11 = (t0 + 1776U);
    t12 = *((char **)t11);
    t11 = (t0 + 4256);
    xsi_vlogvar_wait_assign_value(t11, t12, 0, 0, 24, 0LL);
    xsi_set_current_line(135, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 4096);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    goto LAB58;

LAB40:    xsi_set_current_line(138, ng0);

LAB60:    xsi_set_current_line(139, ng0);
    t3 = (t0 + 1936U);
    t5 = *((char **)t3);
    t3 = (t0 + 4256);
    xsi_vlogvar_wait_assign_value(t3, t5, 0, 0, 24, 0LL);
    goto LAB58;

LAB42:    xsi_set_current_line(142, ng0);

LAB61:    xsi_set_current_line(143, ng0);
    t3 = (t0 + 2096U);
    t5 = *((char **)t3);
    t3 = (t0 + 4256);
    xsi_vlogvar_wait_assign_value(t3, t5, 0, 0, 24, 0LL);
    goto LAB58;

LAB44:    xsi_set_current_line(146, ng0);

LAB62:    xsi_set_current_line(147, ng0);
    t3 = (t0 + 2256U);
    t5 = *((char **)t3);
    t3 = (t0 + 4256);
    xsi_vlogvar_wait_assign_value(t3, t5, 0, 0, 24, 0LL);
    goto LAB58;

LAB46:    xsi_set_current_line(150, ng0);

LAB63:    xsi_set_current_line(151, ng0);
    t3 = (t0 + 2416U);
    t5 = *((char **)t3);
    t3 = (t0 + 4256);
    xsi_vlogvar_wait_assign_value(t3, t5, 0, 0, 24, 0LL);
    goto LAB58;

LAB48:    xsi_set_current_line(154, ng0);

LAB64:    xsi_set_current_line(155, ng0);
    t3 = (t0 + 2576U);
    t5 = *((char **)t3);
    t3 = (t0 + 4256);
    xsi_vlogvar_wait_assign_value(t3, t5, 0, 0, 24, 0LL);
    goto LAB58;

LAB50:    xsi_set_current_line(158, ng0);

LAB65:    xsi_set_current_line(159, ng0);
    t3 = (t0 + 2736U);
    t5 = *((char **)t3);
    t3 = (t0 + 4256);
    xsi_vlogvar_wait_assign_value(t3, t5, 0, 0, 24, 0LL);
    goto LAB58;

LAB52:    xsi_set_current_line(162, ng0);

LAB66:    xsi_set_current_line(163, ng0);
    t3 = (t0 + 2896U);
    t5 = *((char **)t3);
    t3 = (t0 + 4256);
    xsi_vlogvar_wait_assign_value(t3, t5, 0, 0, 24, 0LL);
    goto LAB58;

LAB54:    xsi_set_current_line(166, ng0);

LAB67:    xsi_set_current_line(167, ng0);
    t3 = ((char*)((ng1)));
    t5 = (t0 + 4256);
    xsi_vlogvar_wait_assign_value(t5, t3, 0, 0, 24, 0LL);
    xsi_set_current_line(168, ng0);
    t2 = ((char*)((ng3)));
    t3 = (t0 + 4096);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    goto LAB58;

LAB56:    xsi_set_current_line(171, ng0);

LAB68:    xsi_set_current_line(172, ng0);
    t3 = ((char*)((ng1)));
    t5 = (t0 + 4256);
    xsi_vlogvar_wait_assign_value(t5, t3, 0, 0, 24, 0LL);
    goto LAB58;

LAB71:    t23 = (t13 + 4);
    *((unsigned int *)t13) = 1;
    *((unsigned int *)t23) = 1;
    goto LAB72;

LAB73:    xsi_set_current_line(179, ng0);
    t30 = ((char*)((ng2)));
    t34 = (t0 + 3616);
    xsi_vlogvar_wait_assign_value(t34, t30, 0, 0, 16, 0LL);
    goto LAB75;

}


extern void work_m_00000000004038697402_1999551077_init()
{
	static char *pe[] = {(void *)Always_56_0,(void *)Always_105_1,(void *)Always_122_2};
	xsi_register_didat("work_m_00000000004038697402_1999551077", "isim/led_controller_test_isim_beh.exe.sim/work/m_00000000004038697402_1999551077.didat");
	xsi_register_executes(pe);
}
