<%--
  Created by IntelliJ IDEA.
  User: shilin
  Date: 2020/8/26
  Time: 13:19
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<html>
<head>
    <title>Title</title>
    <script src="https://ajax.aspnetcdn.com/ajax/jquery/jquery-3.5.1.min.js"></script>
    <link href="${pageContext.request.contextPath}/static/bootstrap-3.3.7-dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="${pageContext.request.contextPath}/static/bootstrap-3.3.7-dist/js/bootstrap.min.js"></script>

    <script>
        let pageTotal,currentPage
        let ajax_value
        $(function () {
            to_page(1)
            addEmps()
            saveEmp()
            updateEmps()
            deleteEmp()
            check()
            deleteBatch()
        })

        function to_page(pn) {
            $.ajax({
                url: "${pageContext.request.contextPath}/emps",
                data: "pn=" + pn,
                type: "GET",
                success: function (result) {
                    build_emps_table(result)
                    build_page_info(result)
                    build_page_nav(result)
                }
            })
        }

        function build_emps_table(result) {
            $("#emps_table tbody").empty()
            const empList = result.extend.pageInfo.list;
            $.each(empList, function (index, item) {
                const trCheck = $("<td><input type = 'checkbox' class = 'check_item'></td>")
                const trEmpId = $("<td>").append(item.empId);
                const trEmpNAme = $("<td>").append(item.empName);
                const trGender = $("<td>").append(item.gender === '0' ? '女' : '男');
                const trEmail = $("<td>").append(item.email);
                const trDeptName = $("<td>").append(item.department.deptName);
                const trEditBtn = $("<button>").addClass("btn btn-primary btn-sm edit_btn")
                    .append($("<span>").addClass("glyphicon glyphicon-pencil")).append("编辑");
                trEditBtn.attr("edit_id",item.empId)
                const trDelBtn = $("<button>").addClass("btn btn-danger btn-sm delete_btn")
                    .append($("<span>").addClass("glyphicon glyphicon-trash")).append("删除");
                trDelBtn.attr("del_id",item.empId)
                const td = $("<td>").append(trEditBtn)
                    .append(" ")
                    .append(trDelBtn);
                $("<tr>").append(trCheck)
                    .append(trEmpId)
                    .append(trEmpNAme)
                    .append(trGender)
                    .append(trEmail)
                    .append(trDeptName)
                    .append(td)
                    .appendTo("#emps_table tbody")
            })

        }

        function build_page_info(result) {
            $("#page_info_page").empty()
                .append("当前 " + result.extend.pageInfo.pageNum + " 页, 总 " + result.extend.pageInfo.pages + " 页, 总 " + result.extend.pageInfo.total + " 条记录")
            pageTotal = result.extend.pageInfo.total
            currentPage = result.extend.pageInfo.pageNum
        }

        function build_page_nav(result) {
            const nav = $("<nav>").attr("aria-label", "Page navigation");
            const ul = $("<ul>").addClass("pagination");
            const firstPage = $("<li>").append($("<a href='#'>").append("首页"));

            const lastPage = $("<li>").append($("<a href='#'>").append("尾页"));

            const previous = $("<li>").append($("<a href='#' aria-label='Previous'>").append($("<span aria-hidden='true'>").append("&laquo;")));

            const next = $("<li>").append($("<a href='#' aria-label='Next'>").append($("<span aria-hidden='true'>").append("&raquo;")));

            if (result.extend.pageInfo.hasPreviousPage === false) {
                firstPage.addClass("disabled")
                previous.addClass("disabled")
            } else {
                firstPage.click(function () {
                    to_page(1)
                })
                previous.click(function () {
                    to_page(result.extend.pageInfo.pageNum - 1)
                })
            }
            if (result.extend.pageInfo.hasNextPage === false) {
                next.addClass("disabled")
                lastPage.addClass("disabled")
            } else {
                next.click(function () {
                    to_page(result.extend.pageInfo.pageNum + 1)
                })
                lastPage.click(function () {
                    to_page(result.extend.pageInfo.pages)
                })
            }
            ul.append(firstPage)
            ul.append(previous)
            $.each(result.extend.pageInfo.navigatepageNums, function (index, item) {
                const numLi = $("<li>").append($("<a href='#'>").append(item));
                if (result.extend.pageInfo.pageNum === item) {
                    numLi.addClass("active")
                }
                numLi.click(function () {
                    to_page(item)
                })
                ul.append(numLi)
            })
            ul.append(next)
            ul.append(lastPage)
            nav.append(ul)
            $("#page_info_nav").empty().append(nav)
        }

        function getEmp(id) {
            $.ajax({
                url:"${pageContext.request.contextPath}/emp/" + id,
                type:"GET",
                success:function (result) {
                    // console.log(result)
                    $("#updateEmpName").text(result.extend.emp.empName)
                    $("#updateEmail").val(result.extend.emp.email)
                    /*if (result.extend.emp.gender === "1"){
                        $("#updateMale").attr("checked","").attr("checked","checked")
                    }else {
                        $("#updateFemale").attr("checked","").attr("checked","checked")
                    }*/
                    $(":input[name=gender]").val([result.extend.emp.gender])
                    $("#updateDeptName").val([result.extend.emp.dId])
                }

        })
        }

        function addEmps() {
            getDepts("#deptName")
            $("#addModalBtn").click(function () {
                $("#empForm")[0].reset()
                $("#empName").parent().removeClass("has-success has-error")
                $("#empName").next("span").text("")
                $("#email").parent().removeClass("has-success has-error")
                $("#email").next("span").text("")
                $("#addModal").modal({
                    backdrop: "static"
                })
            })
        }

        function getDepts(element) {
            $.ajax({
                url: "${pageContext.request.contextPath}/depts",
                type: "GET",
                success: function (result) {
                    $.each(result.extend.depts, function (index, item) {
                        $(element).append($("<option>").append(item.deptName).attr("value", item.deptId))
                    })

                }
            })
        }

        function updateEmps() {
            getDepts("#updateDeptName")
            $(document).on("click", ".edit_btn", function () {
                getEmp($(this).attr("edit_id"))
                $("#updateBtn").attr("edit_id",$(this).attr("edit_id"))
                $("#updateModal").modal({
                    backdrop: "static"
                })
            })
            $("#updateBtn").click(function (){
                const email = $("#updateEmail").val()
                // console.log(email)
                const regExpEmail = /^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/
                if (!regExpEmail.test(email)) {
                    show_check_info("#updateEmail", "error", "邮箱格式错误")
                    return false
                } else {
                    show_check_info("#updateEmail", "success", "")
                }
                $.ajax({
                    url:"${pageContext.request.contextPath}/emp/" + $("#updateBtn").attr("edit_id"),
                    type:"PUT",
                    data:$("#updateModal form").serialize(),
                    success:function (result) {
                        console.log(result)
                        $("#updateModal").modal("hide")
                        to_page(currentPage)
                    }
                })
            })

        }

        function saveEmp() {
            check_for_form_ajax()
            // console.log(ajax_value)
            $("#addBtn").click(function () {
                // check_for_form_ajax()
                if ($("#addBtn").attr("ajax_value") === "error") {
                    show_check_info("#empName", "error", "用户名不可用")
                    return false
                }
                if (!check_for_form()) {
                    return false
                }

                $.ajax({
                    url: "${pageContext.request.contextPath}/emp",
                    type: "POST",
                    data: $("#addModal form").serialize(),
                    success: function (result) {
                        if (result.code === 100) {
                            $("#addModal").modal("hide")
                            to_page(pageTotal)
                        } else {
                            // console.log(result)
                            if (result.extend.errorMsg.email !== undefined) {
                                show_check_info("#email", "error", result.extend.errorMsg.email)
                            }
                            if (result.extend.errorMsg.empName !== undefined) {
                                show_check_info("#email", "error", result.extend.errorMsg.empName)
                            }
                        }

                    }
                })
            })
        }

        function deleteEmp() {
            $(document).on("click",".delete_btn",function (){
                const empName = $(this).parents("tr").find("td:eq(2)").text()
                // alert($(this).attr("del_id"))
                if (confirm("确定要删除【" + empName + "】吗")){
                    $.ajax({
                        url:"${pageContext.request.contextPath}/emp/" + $(this).attr("del_id"),
                        type:"DELETE",
                        success:function (result) {
                            alert(result.msg)
                            to_page(currentPage)
                        }
                    })
                }

            })
        }

        function deleteBatch() {
                $("#deleteAll").click(function (){
                    // alert(1)
                    let empNames = "";
                    let empIds = "";
                    $.each($(".check_item:checked"),function (){
                        empNames = empNames += $(this).parents("tr").find("td:eq(2)").text() + ","
                        empIds = empIds += $(this).parents("tr").find("td:eq(1)").text() + "-"
                    })
                    empNames = empNames.substring(0,empNames.length - 1)
                    empIds.substring(0,empIds.length - 1)
                    if ($(".check_item:checked").length !== 0){
                        if (confirm("确定删除【"+ empNames +"】吗")){
                            $.ajax({
                                url:"${pageContext.request.contextPath}/emp/" + empIds,
                                type:"DELETE",
                                success:function (result) {
                                    alert(result.msg)
                                    to_page(currentPage)
                                }
                            })
                        }
                    }

                })

        }
        function check_for_form() {
            const empName = $("#empName").val()
            const regExpName = /(^[a-zA-Z0-9_-]{6,16}$)|(^[\u2E80-\u9FFF]{3,5}$)/
            if (!regExpName.test(empName.trim())) {
                show_check_info("#empName", "error", "用户名格式错误，请输入6-16位 ‘a-z A-Z 0-9 _ -’ 或3-5位汉字")
                return false
            } else {
                show_check_info("#empName", "success", "")
            }
            const email = $("#email").val()
            console.log(email)
            const regExpEmail = /^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/
            if (!regExpEmail.test(email)) {
                show_check_info("#email", "error", "邮箱格式错误")
                return false
            } else {
                show_check_info("#email", "success", "")
            }
            return true
        }

        function check_username() {
            $.ajax({
                url: "${pageContext.request.contextPath}/checkUsername",
                type: "POST",
                data: "empName=" + $("#empName").val(),
                success: function (result) {
                    if (result.code === 100) {
                        // console.log(result.code)
                        show_check_info("#empName", "success", "")
                        /*console.log(ajax_value)
                        ajax_value = "success"
                        console.log(ajax_value)*/
                        $("#addBtn").attr("ajax_value", "success")
                    } else {
                        // console.log(result.code)
                        show_check_info("#empName", "error", result.extend.check_msg)
                        // console.log(result.extend.check_msg)
                        // ajax_value = "error"
                        $("#addBtn").attr("ajax_value", "error")
                    }
                }
            })
        }

        function check_for_form_ajax() {
            $("#empName").blur(function () {
                // alert(1)
                check_username()
            })
        }

        function show_check_info(element, status, message) {
            if ("error" === status) {
                $(element).parent().addClass("has-error")
                $(element).next("span").text(message)
            }
            if ("success" === status) {
                $(element).parent().removeClass("has-error").addClass("has-success")
                $(element).next("span").text("")
            }
        }
        function check() {
            $("#check_check").click(function (){
                $(".check_item").prop("checked",$(this).prop("checked"))
            })
            // alert($(".check_item").length)
            $(document).on("click",".check_item",function (){
                $("#check_check").prop("checked",$(".check_item:checked").length === $(".check_item").length)
            })

        }
    </script>

</head>
<body>
<div class="container">
    <div class="row">
        <div class="col-md-12">
            <h1>ssm-crud</h1>
        </div>
    </div>
    <div class="row">
        <div class="col-md-4 col-md-offset-8">
            <button class="btn btn-primary" id="addModalBtn">新增</button>
            <!-- 员工添加 -->
            <div class="modal fade" id="addModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span
                                    aria-hidden="true">&times;</span></button>
                            <h4 class="modal-title" id="myModalLabel">员工添加</h4>
                        </div>
                        <div class="modal-body">
                            <form class="form-horizontal" id="empForm">
                                <div class="form-group">
                                    <label for="empName" class="col-sm-2 control-label">empName</label>
                                    <div class="col-sm-10">
                                        <input type="text" class="form-control" name="empName" id="empName"
                                               placeholder="empName">
                                        <span class="help-block"></span>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label for="email" class="col-sm-2 control-label">email</label>
                                    <div class="col-sm-10">
                                        <input type="email" class="form-control" name="email" id="email"
                                               placeholder="email@example.com">
                                        <span class="help-block"></span>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label for="male" class="col-sm-2 control-label">gender</label>
                                    <div class="col-sm-10">
                                        <label class="radio-inline">
                                            <input type="radio" name="gender" id="male" value="1" checked> 男
                                        </label>
                                        <label class="radio-inline">
                                            <input type="radio" name="gender" id="female" value="0"> 女
                                        </label>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label for="deptName" class="col-sm-2 control-label">deptName</label>
                                    <div class="col-sm-4">
                                        <select class="form-control" name="dId" id="deptName">

                                        </select>
                                    </div>
                                </div>
                            </form>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                            <button type="button" class="btn btn-primary" id="addBtn">保存</button>
                        </div>
                    </div>
                </div>
            </div>
            <button class="btn btn-danger" id="deleteAll">删除</button>
        </div>
    </div>
    <div class="row">
        <div class="col-md-12">
            <%--员工修改--%>
            <div class="modal fade" id="updateModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span
                                    aria-hidden="true">&times;</span></button>
                            <h4 class="modal-title" id="myUpdateModalLabel">员工修改</h4>
                        </div>
                        <div class="modal-body">
                            <form class="form-horizontal">
                                <div class="form-group">
                                    <label for="updateEmpName" class="col-sm-2 control-label">empName</label>
                                    <div class="col-sm-10">
                                        <p class="form-control-static" id="updateEmpName">empName</p>
                                        <%--<input type="text" class="form-control" name="empName"
                                               id="updateEmpName" &lt;%&ndash;placeholder="empName"&ndash;%&gt;>
                                        &lt;%&ndash;<span class="help-block"></span>&ndash;%&gt;--%>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label for="updateEmail" class="col-sm-2 control-label">email</label>
                                    <div class="col-sm-10">
                                        <input type="email" class="form-control" name="email"
                                               id="updateEmail" <%--placeholder="email@example.com"--%>>
                                        <span class="help-block"></span>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label for="updateMale" class="col-sm-2 control-label">gender</label>
                                    <div class="col-sm-10">
                                        <label class="radio-inline">
                                            <input type="radio" name="gender" id="updateMale" value="1"> 男
                                        </label>
                                        <label class="radio-inline">
                                            <input type="radio" name="gender" id="updateFemale" value="0"> 女
                                        </label>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label for="updateDeptName" class="col-sm-2 control-label">deptName</label>
                                    <div class="col-sm-4">
                                        <select class="form-control" name="dId" id="updateDeptName">

                                        </select>
                                    </div>
                                </div>
                            </form>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                            <button type="button" class="btn btn-primary" id="updateBtn">修改</button>
                        </div>
                    </div>
                </div>
            </div>
            <table class="table table-hover" id="emps_table">
                <thead>
                <tr>
                    <th><input type="checkbox" id="check_check"></th>
                    <th>#</th>
                    <th>empName</th>
                    <th>gender</th>
                    <th>email</th>
                    <th>deptName</th>
                    <th>编辑</th>
                </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>
    </div>
    <div class="row" id="page_info">
        <div class="col-md-6" id="page_info_page">
        </div>
        <div class="col-md-6" id="page_info_nav">
        </div>
    </div>
</div>
</body>
</html>
