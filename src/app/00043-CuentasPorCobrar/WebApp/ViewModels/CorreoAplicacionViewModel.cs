using Domain.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public partial class CorreoAplicacionViewModel
    {
        public int? MailId { get; set; }

        [Required]
        [StringLength(250)]
        [Display(Name = "Nombre del Host")]
        public string HostName { get; set; }

        [Required]
        [StringLength(250)]
        [Display(Name = "Dirección de Correo")]
        public string MailAddress { get; set; }

        [Required]
        [StringLength(500)]
        [DataType(DataType.Password)]
        [Display(Name = "Contraseña")]
        public string Password { get; set; }

        [Required]
        [StringLength(20)]
        [Display(Name = "Tipo de Seguridad")]
        public string SecurityType { get; set; }

        [Required]
        [Display(Name = "Número de puerto")]
        public int PortNumber { get; set; }

        [Display(Name = "Estado de la cuenta")]
        public bool? Enabled { get; set; }

        [Display(Name = "Última Actualización")]
        public DateTime FecUpdate { get; set; }


        public CorreoAplicacionViewModel() { }

        public CorreoAplicacionViewModel(CorreoAplicacion correoAplicacion)
        {
            this.MailId = correoAplicacion.Id;
            this.HostName = correoAplicacion.HostName;
            this.MailAddress = correoAplicacion.Address;
            this.Password = correoAplicacion.Password;
            this.SecurityType = correoAplicacion.SecurityType;
            this.PortNumber = correoAplicacion.Port;
            this.Enabled = correoAplicacion.Enabled;
            this.FecUpdate = correoAplicacion.FecUpdated;
        }
    }

}