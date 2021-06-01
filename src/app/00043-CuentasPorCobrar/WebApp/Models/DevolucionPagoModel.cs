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
    public class DevolucionPagoModel
    {
        private readonly IDevolucionPago _devolucionPago;
        public DevolucionPagoModel()
        {
            _devolucionPago = new DevolucionPago();
        }

        public List<DevolucionesViewModel> Find()
        {
            List<DevolucionesViewModel> result = new List<DevolucionesViewModel>();

            foreach (var item in _devolucionPago.Find())
            {
                result.Add(new DevolucionesViewModel(item));
            }

            return result;
        }

        public RegistrarDevolucionPagoViewModel Find(int entidadFinancieraId)
        {
            return new RegistrarDevolucionPagoViewModel(_devolucionPago.Find(entidadFinancieraId));
        }

        public Response ChangeState(int entidadFinancieraId, bool currentState, int currentUserId, string returnUrl)
        {
            Response result = _devolucionPago.ChangeState(entidadFinancieraId, currentState, currentUserId);

            result.Redirect = returnUrl;

            return result;
        }


        public Response Save(RegistrarDevolucionPagoViewModel model, int currentUserId)
        {
            DevolucionPago devolucionPago = new DevolucionPago()
            {
                DevolucionId = model.DevolucionId ?? 0,
                EntidadRecaudadoraId = model.EntidadRecaudadora,
                PagoReferenciaId = model.PagoReferenciaId,
                MontoDevolucion = model.MontoDevolucion,
                FecAprueba = model.FecAprueba,
                FecDevuelve = model.FecDevuelve,
                NroSIAF = model.NroSIAF.ToString()
            };

            Response result = _devolucionPago.Save(devolucionPago, currentUserId, (devolucionPago.DevolucionId == 0 ? SaveOption.Insert : SaveOption.Update));

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