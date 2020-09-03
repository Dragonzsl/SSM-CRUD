package com.shilin.controller;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.shilin.bean.Employee;
import com.shilin.bean.Msg;
import com.shilin.service.EmployeeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author shilin
 * @create 2020-08-25 17:23
 */
@Controller
public class EmployeeController {
    @Autowired
    EmployeeService employeeService;

    //    @RequestMapping("/emps")
    /*public String getEmps(@RequestParam(value = "pn", defaultValue = "1") Integer pn, Model model) {
        PageHelper.startPage(pn, 5);
        List<Employee> emps = employeeService.getEmps();
        PageInfo<Employee> employeePageInfo = new PageInfo<>(emps, 5);
        model.addAttribute("pageInfo", employeePageInfo);
        return "list";
    }*/

    @RequestMapping("/emps")
    @ResponseBody
    public Msg getEmpsWithJson(@RequestParam(value = "pn", defaultValue = "1") Integer pn) {
        PageHelper.startPage(pn, 5);
        List<Employee> emps = employeeService.getEmps();
        PageInfo<Employee> employeePageInfo = new PageInfo<>(emps, 5);
        return Msg.success().add("pageInfo", employeePageInfo);
    }

    @RequestMapping(value = "/emp",method = RequestMethod.POST)
    @ResponseBody
    public Msg saveEmp(@Validated Employee employee, BindingResult result) {

        Map<String ,Object> map = new HashMap<>();
        if (result.hasErrors()){
            List<FieldError> fieldErrors = result.getFieldErrors();
            for (FieldError error:fieldErrors){
                map.put(error.getField(), error.getDefaultMessage());
            }
            return Msg.fail().add("errorMsg", map);
        }else {
            employeeService.saveEmp(employee);
            return Msg.success();
        }

    }

    @RequestMapping("/checkUsername")
    @ResponseBody
    public Msg checkUsername(String empName){
        boolean result = employeeService.checkUsername(empName);
        String regExp = "(^[a-zA-Z0-9_-]{6,16}$)|(^[\\u2E80-\\u9FFF]{3,5}$)";
        boolean matches = empName.matches(regExp);
        if (!matches){
            return Msg.fail().add("check_msg", "用户名格式错误，请输入6-16位 ‘a-z A-Z 0-9 _ -’ 或3-5位汉字");
        }
        if (result){
            return Msg.success();
        }else {
           return Msg.fail().add("check_msg","用户名不可用");
        }
    }
    @RequestMapping(value = "/emp/{id}",method = RequestMethod.GET)
    @ResponseBody
    public Msg getEmp(@PathVariable("id") Integer id){
        Employee employee = employeeService.getEmp(id);
        return Msg.success().add("emp", employee);
    }

    @RequestMapping(value = "/emp/{empId}",method = RequestMethod.PUT)
    @ResponseBody
    public Msg saveEmployee(Employee employee){
        employeeService.updateEmp(employee);
        return Msg.success();
    }

    @RequestMapping(value = "/emp/{ids}",method = RequestMethod.DELETE)
    @ResponseBody
    public Msg deleteEmp(@PathVariable("ids") String  ids){
        List<Integer> list = new ArrayList<>();
        if (ids.contains("-")){
            String[] str_id = ids.split("-");
            for (String str:str_id){
                list.add(Integer.valueOf(str));
            }
            employeeService.deleteBatch(list);
        }else {
            int id = Integer.parseInt(ids);
            employeeService.deleteEmp(id);
        }
        return Msg.success();
    }
}
