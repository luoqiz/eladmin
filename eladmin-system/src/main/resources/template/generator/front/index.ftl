<#--noinspection ALL-->
<template>
  <div class="app-container">
    <!--工具栏-->
    <div class="head-container">
    <#if hasQuery>
      <div v-if="crud.props.searchToggle">
        <!-- 搜索 -->
        <#if queryColumns??>
          <#list queryColumns as column>
            <#if column.queryType != 'BetWeen'>
        <label class="el-form-item-label"><#if column.remark != ''>${column.remark}<#else>${column.changeColumnName}</#if></label>
              <#if column.formType = 'Radio'>
                <#if (column.dictName)?? && (column.dictName)!="">
        <el-radio v-model="query.${column.changeColumnName}" v-for="item in dict.${column.dictName}" :key="item.id" :label="item.value">{{ item.label }}</el-radio>
                <#else>
                  未设置字典，请手动设置 Radio
                </#if>
              <#elseif column.formType = 'Select'>
                <#if (column.dictName)?? && (column.dictName)!="">
        <el-select v-model="query.${column.changeColumnName}" clearable filterable placeholder="请选择">
          <el-option v-for="item in dict.${column.dictName}"
                               :key="item.id"
                               :label="item.label"
                               :value="item.value" />
        </el-select>
                <#else>
                  未设置字典，请手动设置 Select
                </#if>
              <#else>
        <el-input v-model="query.${column.changeColumnName}" clearable placeholder="<#if column.remark != ''>${column.remark}<#else>${column.changeColumnName}</#if>" style="width: 185px;" class="filter-item" @keyup.enter.native="crud.toQuery" />
              </#if>
            </#if>
          </#list>
        </#if>
  <#if betweens??>
    <#list betweens as column>
      <#if column.queryType = 'BetWeen'>
        <date-range-picker
          v-model="query.${column.changeColumnName}"
          start-placeholder="${column.changeColumnName}Start"
          end-placeholder="${column.changeColumnName}Start"
          class="date-item"
        />
      </#if>
    </#list>
  </#if>
        <rrOperation :crud="crud" />
      </div>
    </#if>
      <!--如果想在工具栏加入更多按钮，可以使用插槽方式， slot = 'left' or 'right'-->
      <crudOperation :permission="permission" />
      <!--表单组件-->
      <el-dialog :close-on-click-modal="false" :before-close="crud.cancelCU" :visible.sync="crud.status.cu > 0" :title="crud.status.title" width="500px" @opened="show(form)" @closed="hide()">
        <el-form ref="form" :model="form" <#if isNotNullColumns??>:rules="rules"</#if> size="small" label-width="80px">
    <#if columns??>
      <#list columns as column>
        <#if column.formShow>
          <el-form-item label="<#if column.remark != ''>${column.remark}<#else>${column.changeColumnName}</#if>"<#if column.istNotNull> prop="${column.changeColumnName}"</#if>>
            <#if column.formType = 'Input'>
            <el-input v-model="form.${column.changeColumnName}" style="width: 370px;" />
            <#elseif column.formType = 'Textarea'>
            <el-input v-model="form.${column.changeColumnName}" :rows="3" type="textarea" style="width: 370px;" />
            <#elseif column.formType = 'Radio'>
              <#if (column.dictName)?? && (column.dictName)!="">
            <el-radio v-model="form.${column.changeColumnName}" v-for="item in dict.${column.dictName}" :key="item.id" :label="item.value">{{ item.label }}</el-radio>
              <#else>
                未设置字典，请手动设置 Radio
              </#if>
            <#elseif column.formType = 'Select'>
              <#if (column.dictName)?? && (column.dictName)!="">
            <el-select v-model="form.${column.changeColumnName}" filterable placeholder="请选择">
              <el-option
                v-for="item in dict.${column.dictName}"
                :key="item.id"
                :label="item.label"
                :value="item.value" />
            </el-select>
              <#else>
            未设置字典，请手动设置 Select
              </#if>
            <#elseif column.formType = 'wangeditor'>
            <div ref="${column.changeColumnName}editor" class="text" style="width: auto;height: 400px;" />
            <#else>
            <el-date-picker v-model="form.${column.changeColumnName}" type="datetime" style="width: 370px;" />
            </#if>
          </el-form-item>
        </#if>
      </#list>
    </#if>
        </el-form>
        <div slot="footer" class="dialog-footer">
          <el-button type="text" @click="crud.cancelCU">取消</el-button>
          <el-button :loading="crud.cu === 2" type="primary" @click="crud.submitCU">确认</el-button>
        </div>
      </el-dialog>
      <!--表格渲染-->
      <el-table ref="table" v-loading="crud.loading" :data="crud.data" size="small" style="width: 100%;" @selection-change="crud.selectionChangeHandler">
        <el-table-column type="selection" width="55" />
        <#if columns??>
            <#list columns as column>
              <#if column.columnShow>
                <#if (column.dictName)?? && (column.dictName)!="">
        <el-table-column prop="${column.changeColumnName}" label="<#if column.remark != ''>${column.remark}<#else>${column.changeColumnName}</#if>">
          <template slot-scope="scope">
            {{ dict.label.${column.dictName}[scope.row.${column.changeColumnName}] }}
          </template>
        </el-table-column>
                <#elseif column.columnType != 'Timestamp'>
                  <#if column.formType = 'wangeditor'>
        <el-table-column prop="${column.changeColumnName}" label="<#if column.remark != ''>${column.remark}<#else>${column.changeColumnName}</#if>">
          <template slot-scope="scope">
            <div v-html="scope.row.${column.changeColumnName}" />
          </template>
        </el-table-column>
                  <#else>
        <el-table-column prop="${column.changeColumnName}" label="<#if column.remark != ''>${column.remark}<#else>${column.changeColumnName}</#if>" />
                  </#if>
                <#else>
        <el-table-column prop="${column.changeColumnName}" label="<#if column.remark != ''>${column.remark}<#else>${column.changeColumnName}</#if>">
          <template slot-scope="scope">
            <span>{{ parseTime(scope.row.${column.changeColumnName}) }}</span>
          </template>
        </el-table-column>
                </#if>
              </#if>
            </#list>
        </#if>
        <el-table-column v-permission="['admin','${changeClassName}:edit','${changeClassName}:del']" label="操作" width="150px" align="center">
          <template slot-scope="scope">
            <udOperation
              :data="scope.row"
              :permission="permission"
            />
          </template>
        </el-table-column>
      </el-table>
      <!--分页组件-->
      <pagination />
    </div>
  </div>
</template>

<script>
import crud${className} from '@/api/${changeClassName}'
import CRUD, { presenter, header, form, crud } from '@crud/crud'
import rrOperation from '@crud/RR.operation'
import crudOperation from '@crud/CRUD.operation'
import udOperation from '@crud/UD.operation'
import pagination from '@crud/Pagination'

const defaultForm = { <#if columns??><#list columns as column>${column.changeColumnName}: null<#if column_has_next>, </#if></#list></#if> }
export default {
  name: '${className}',
  components: { pagination, crudOperation, rrOperation, udOperation },
  mixins: [presenter(), header(), form(defaultForm), crud()],
  <#if hasDict>
  dicts: [<#if hasDict??><#list dicts as dict>'${dict}'<#if dict_has_next>, </#if></#list></#if>],
  </#if>
  cruds() {
    return CRUD({ title: '${apiAlias}', url: 'api/${changeClassName}', sort: '${pkChangeColName},desc', crudMethod: { ...crud${className} }})
  },
  data() {
    return {
      permission: {
        add: ['admin', '${changeClassName}:add'],
        edit: ['admin', '${changeClassName}:edit'],
        del: ['admin', '${changeClassName}:del']
      },
      rules: {
        <#if isNotNullColumns??>
        <#list isNotNullColumns as column>
        <#if column.istNotNull>
        ${column.changeColumnName}: [
          { required: true, message: '<#if column.remark != ''>${column.remark}</#if>不能为空', trigger: 'blur' }
        ]<#if column_has_next>,</#if>
        </#if>
        </#list>
        </#if>
      }<#if hasQuery>,
      queryTypeOptions: [
        <#if queryColumns??>
        <#list queryColumns as column>
        <#if column.queryType != 'BetWeen'>
        { key: '${column.changeColumnName}', display_name: '<#if column.remark != ''>${column.remark}<#else>${column.changeColumnName}</#if>' }<#if column_has_next>,</#if>
        </#if>
        </#list>
        </#if>
      ]
      </#if>
    }
  },
  methods: {
    // 钩子：在获取表格数据之前执行，false 则代表不获取数据
    [CRUD.HOOK.beforeRefresh]() {
      return true
    },
    show(form) {
      const _this = this
      <#if columns??>
      <#list columns as column>
      <#if column.formType = 'wangeditor'>
      var ${column.changeColumnName}editor = new E(this.$refs.${column.changeColumnName}editor)
      // 自定义菜单配置
      ${column.changeColumnName}editor.customConfig.zIndex = 1
      ${column.changeColumnName}editor.customConfig.uploadImgShowBase64 = true
      // 文件上传
      ${column.changeColumnName}editor.customConfig.customUploadImg = function(files, insert) {
        // files 是 input 中选中的文件列表
        // insert 是获取图片 url 后，插入到编辑器的方法
        files.forEach(image => {
          upload(_this.imagesUploadApi, image).then(data => {
            insert(data.data.url)
          })
        })
      }
      ${column.changeColumnName}editor.customConfig.onchange = (html) => {
        console.log(html)
        // this.editorContent = html
        // this.form.content = html
        form.content = html
      }
      ${column.changeColumnName}editor.create()
      // 初始化数据
      ${column.changeColumnName}editor.txt.html(form.content)
      </#if>
      </#list>
      </#if>
    },
    hide() {
      this.$refs.editor.innerHTML = ''
      this.editor = null
    }
  }
}
</script>

<style scoped>

</style>
