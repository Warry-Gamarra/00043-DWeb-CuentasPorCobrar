using Domain.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class CuentaDepositoViewModel
    {
        public int? Id { get; set; }
        public int EntidadFinancieraId { get; set; }
        public string EntidadFinanciera { get; set; }
        public string Descripcion { get; set; }
        public string NumeroCuenta { get; set; }
        public string DescripcionFull { get { return $"{Descripcion} - {NumeroCuenta}"; } }
        public string Observacion { get; set; }

        public bool Habilitado { get; set; }

        public CuentaDepositoViewModel() { }

        public CuentaDepositoViewModel(CuentaDeposito cuentaDeposito)
        {
            this.Id = cuentaDeposito.I_CtaDepID;
            this.Descripcion = cuentaDeposito.T_DescCuenta == null ? "" : cuentaDeposito.T_DescCuenta.ToUpper();
            this.NumeroCuenta = cuentaDeposito.C_NumeroCuenta;
            this.EntidadFinancieraId = cuentaDeposito.I_EntidadFinanId;
            this.EntidadFinanciera = cuentaDeposito.T_EntidadDesc;
            this.Observacion = cuentaDeposito.T_Observacion;
            this.Habilitado = cuentaDeposito.Habilitado;
        }

    }


    public class CuentaDepositoRegistroViewModel
    {
        public int? Id { get; set; }
        [Display(Name = "Entidad Recaudadora")]
        [Required]
        public int EntidadRecaudadoraId { get; set; }

        [Display(Name = "Descripción")]
        [Required]
        [StringLength(maximumLength: 150)]
        public string Descripcion { get; set; }

        [Display(Name = "Número de cuenta")]
        [Required]
        [StringLength(maximumLength: 50)]
        public string NumeroCuenta { get; set; }

        [Display(Name = "Observación")]
        [StringLength(maximumLength: 500)]
        public string Observacion { get; set; }


        public CuentaDepositoRegistroViewModel() { }

        public CuentaDepositoRegistroViewModel(CuentaDeposito cuentaDeposito)
        {
            this.Id = cuentaDeposito.I_CtaDepID;
            this.Descripcion = cuentaDeposito.T_DescCuenta;
            this.NumeroCuenta = cuentaDeposito.C_NumeroCuenta;
            this.EntidadRecaudadoraId = cuentaDeposito.I_EntidadFinanId;
            this.Observacion = cuentaDeposito.T_Observacion;
        }

    }
}