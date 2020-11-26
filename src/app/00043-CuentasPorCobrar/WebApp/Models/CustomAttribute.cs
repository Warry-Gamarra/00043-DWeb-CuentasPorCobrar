using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;
using System.Web.Mvc;

namespace System.ComponentModel.DataAnnotations
{
    public sealed class RequiredWhenBoolenIsTrueAttribute : ValidationAttribute, IClientValidatable
    {
        private string BooleanPropertyName { get; set; }

        public RequiredWhenBoolenIsTrueAttribute(string booleanPropertyName)
            : base ("El campo {0} es requerido.")
        {
            this.BooleanPropertyName = booleanPropertyName;
        }

        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            var booleanPropertyInfo = validationContext.ObjectType.GetProperty(this.BooleanPropertyName);

            if (booleanPropertyInfo == null)
            {
                return new ValidationResult(string.Format("Unknown property {0}.", this.BooleanPropertyName));
            }

            var booleanPropertyValue = (bool)booleanPropertyInfo.GetValue(validationContext.ObjectInstance, null);

            return (booleanPropertyValue && value == null) ?
                new ValidationResult(FormatErrorMessage(validationContext.DisplayName)) : ValidationResult.Success;
        }

        public IEnumerable<ModelClientValidationRule> GetClientValidationRules(ModelMetadata metadata, ControllerContext context)
        {
            var rule = new ModelClientValidationRule
            {
                ErrorMessage = FormatErrorMessage(metadata.GetDisplayName()),
                ValidationType = "requiredwhenboolenistrue"
            };

            rule.ValidationParameters.Add("booleanpropertyname", BooleanPropertyName);

            yield return rule;
        }
    }

    public sealed class AmountGreaterThanZeroAttribute : ValidationAttribute, IClientValidatable
    {
        public AmountGreaterThanZeroAttribute()
            : base ("El campo {0} debe ser mayor a 0.") { }

        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            if (value == null)
            {
                return ValidationResult.Success;
            }

            if (!value.GetType().Equals(typeof(decimal)))
            {
                return new ValidationResult(string.Format("Incorrect type for {0}.", validationContext.MemberName));
            }

            decimal currentAmount = (decimal)value;

            return currentAmount > 0 ? ValidationResult.Success :
                new ValidationResult(FormatErrorMessage(validationContext.DisplayName));
        }

        public IEnumerable<ModelClientValidationRule> GetClientValidationRules(ModelMetadata metadata, ControllerContext context)
        {
            var rule = new ModelClientValidationRule
            {
                ErrorMessage = FormatErrorMessage(metadata.GetDisplayName()),
                ValidationType = "amountgreaterthanzero"
            };

            yield return rule;
        }
    }
}