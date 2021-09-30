<#import "/library/pattern_functions.ftl" as function />

<#--stop if modelObject is null-->
<#if !(modelObject)??>  <#stop "modelObject not found in context" ></#if>

<#--stop if generatedJavaMethod is null-->
<#if !(generatedJavaMethod)??>  <#stop "generatedJavaMethod not found in context. It contains the ast of the created method" ></#if>

<#--stop if comparatorFactory is null-->
<#if !(comparatorFactory)??>  <#stop "comparatorFactory not found in context" ></#if>

<#-- Here we show an example of a hashCode implementation with use of the Apache Commons library. -->

<#-- Add import for HashCodeBuilder to the class imports -->
${metafactory.addImportToClass("org.apache.commons.lang3.builder.HashCodeBuilder")}

<#-- Retrieve the ast object of the method created by the code instruction and add some extra text -->
<#assign apicomment = generatedJavaMethod.apiComment />
<#assign apicommentText>
    ${apicomment}
    Fields used as business key:
</#assign>

<#-- This is actual hashCode implementation -->
return new HashCodeBuilder()
    <@generateHashCodeForBKAttributes />
    .toHashCode();

<#-- Now set the apicomment we created in this template to the ast object of the method -->
<#assign apicommentText = "${apicommentText}." />
${generatedJavaMethod.setApiComment(apicommentText)}

<#--------------------------------------------------------------------------------------------------------------------->

<#macro generateHashCodeForBKAttributes>
    <#local bkAttributes = modelObject.findAttributesByMetaData("businesskey") />
    <#local comparator = comparatorFactory.createMetaDataComparator("businesskey") />
    <#local sortedBkAttributes = metafactory.sort(bkAttributes, comparator) />
    <#list sortedBkAttributes as attribute>
        <#local attributeName = attribute.name />
        <#local attributeType = attribute.type />
        <#local attributeNameFU = attributeName?cap_first />
        <#if metafactory.getJavaType(attributeType) == "boolean">
            <#local getter = "is${attributeNameFU}" />
        <#else>
            <#local getter = "get${attributeNameFU}" />
        </#if>
        .append(this.${getter}())

        <#--Add this attribute to the apicomment -->
        <#local counter = attribute.getMetaData("businesskey") />
        <#local previousComment = apicommentText />
        <#assign apicommentText = " ${previousComment} ${counter}) ${attributeName}" />
    </#list>
</#macro>