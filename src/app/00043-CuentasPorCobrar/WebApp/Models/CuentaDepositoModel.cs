using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Domain.Helpers;
using Domain.Entities;
using Domain.Services;
using WebApp.ViewModels;

namespace WebApp.Models
{
    public class CuentaDepositoModel
    {
        private readonly ICuentaDeposito _cuentaDeposito;
        public CuentaDepositoModel()
        {
            _cuentaDeposito = new CuentaDeposito();
        }


        public List<CuentaDepositoViewModel> Find()
        {
            var result = new List<CuentaDepositoViewModel>();

            foreach (var item in _cuentaDeposito.Find())
            {
                result.Add(new CuentaDepositoViewModel(item)
                {
                    Observacion = string.IsNullOrEmpty(item.T_Observacion) ? "(Ninguna)" : item.T_Observacion
                });
            }

            return result;
        }

        public CuentaDepositoRegistroViewModel Find(int cuentaDepositoId)
        {
            return new CuentaDepositoRegistroViewModel(_cuentaDeposito.Find(cuentaDepositoId));
        }

        public Response ChangeState(int entidadFinancieraId, bool currentState, int currentUserId, string returnUrl)
        {
            Response result = _cuentaDeposito.ChangeState(entidadFinancieraId, currentState, currentUserId);

            result.Redirect = returnUrl;

            return result;
        }


        public Response Save(CuentaDepositoRegistroViewModel model, int currentUserId)
        {
            CuentaDeposito cuentaDeposito = new CuentaDeposito()
            {
                I_CtaDepID = model.Id ?? 0,
                T_DescCuenta = model.Descripcion.ToUpper(),
                C_NumeroCuenta = model.NumeroCuenta.ToUpper(),
                I_EntidadFinanId = model.EntidadFinancieraId,
                T_Observacion = string.IsNullOrEmpty(model.Observacion) ? model.Observacion : model.Observacion.ToUpper(),
                Habilitado = true,
                FechaActualiza = DateTime.Now
            };

            Response result = _cuentaDeposito.Save(cuentaDeposito, currentUserId, (cuentaDeposito.I_CtaDepID == 0 ? SaveOption.Insert : SaveOption.Update));

            if (result.Value)
            {
                result.Success(false);
            }
            else
            {
                result.Error(true);
            }
            return result;
        }

    }
}