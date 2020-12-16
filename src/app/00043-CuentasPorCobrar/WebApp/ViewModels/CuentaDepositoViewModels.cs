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
        public string EntidadFinanciera { get; set; }
        public string NumeroCuenta { get; set; }
        public string Observacion { get; set; }

        public bool Habilitado { get; set; }

        public CuentaDepositoViewModel() { }

        public CuentaDepositoViewModel(CuentaDeposito cuentaDeposito) {
            this.Id = cuentaDeposito.I_CtaDepID;
            this.NumeroCuenta = cuentaDeposito.C_NumeroCuenta;
            this.EntidadFinanciera = cuentaDeposito.T_EntidadDesc;
            this.Observacion = cuentaDeposito.T_Observacion;
            this.Habilitado = cuentaDeposito.Habilitado;
        }

    }


    public class CuentaDepositoRegistroViewModel
    {
        public int? Id { get; set; }
        [Display(Name = "Entidad Financiera")]
        [Required]
        public int EntidadFinancieraId { get; set; }

        [Display(Name = "Número de cuenta")]
        [Required]
        public string NumeroCuenta { get; set; }

        [Display(Name = "Observación")]
        public string Observacion { get; set; }


        public CuentaDepositoRegistroViewModel() { }

        public CuentaDepositoRegistroViewModel(CuentaDeposito cuentaDeposito)
        {
            this.Id = cuentaDeposito.I_CtaDepID;
            this.NumeroCuenta = cuentaDeposito.C_NumeroCuenta;
            this.EntidadFinancieraId = cuentaDeposito.I_EntidadFinanId;
            this.Observacion = cuentaDeposito.T_Observacion;
        }

    }
}