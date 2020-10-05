using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public partial class MailAdminViewModel
    {
        public int? MailID { get; set; }

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
        public int? PortNumber { get; set; }

        [Display(Name = "Estado de la cuenta")]
        public bool? Enabled { get; set; }

        [Display(Name = "Última Actualización")]
        public DateTime FecUpdate { get; set; }


        public MailAdminViewModel() { }

        //public CorreoAdminViewModel(CuentaCorreo correo)
        //{
        //    this.idCorreo = correo.I_CorreoID;
        //    this.hostName = correo.T_HostName;
        //    this.mailAddress = correo.T_DireccionCorreo;
        //    this.password = correo.T_PasswordCorreo;
        //    this.securityType = correo.T_Seguridad;
        //    this.portNumber = correo.I_Puerto;
        //    this.estado = correo.B_Habilitado;
        //    this.fecUpdate = correo.D_FecUpdate;
        //    this.programaID = correo.I_ProgramaID;
        //    this.programa = programaID.HasValue ? correo.T_ProgramaNom : "PARA ACTIVIDADES DE ADMINISTRACIÓN";
        //}
    }

}