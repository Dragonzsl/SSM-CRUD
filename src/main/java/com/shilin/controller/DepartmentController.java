package com.shilin.controller;

import com.shilin.bean.Department;
import com.shilin.bean.Msg;
import com.shilin.service.DepartmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

/**
 * @author shilin
 * @create 2020-08-27 12:33
 */
@Controller
public class DepartmentController {
    @Autowired
    DepartmentService departmentService;

    @RequestMapping("/depts")
    @ResponseBody
    public Msg getDepts() {
        List<Department> departmentList = departmentService.getDepts();
        return Msg.success().add("depts", departmentList);
    }
}
