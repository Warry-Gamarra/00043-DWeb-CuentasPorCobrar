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

        public RegistrarDevolucionPagoViewModel Find(int devolucionId)
        {
            return new RegistrarDevolucionPagoViewModel(_devolucionPago.Find(devolucionId));
        }

        public List<RegistrarDevolucionPagoViewModel> Find(int entidadId, string codOperacion)
        {
            var result = new List<RegistrarDevolucionPagoViewModel>();

            foreach (var item in _devolucionPago.Find().Where(x => x.EntidadRecaudadoraId == entidadId && x.CodOperacionPago == codOperacion))
            {
                result.Add(new RegistrarDevolucionPagoViewModel(item));
            }
            return result;
        }

        public Response AnularDevolucion(int devolucionPagoId, int currentUserId)
        {
            Response result = _devolucionPago.AnularDevolucion(devolucionPagoId, currentUserId);

            return result;
        }


        public Response Save(RegistrarDevolucionPagoViewModel model, int currentUserId)
        {
            DevolucionPago devolucionPago = new DevolucionPago()
            {
                DevolucionId = model.DevolucionId ?? 0,
                EntidadRecaudadoraId = model.EntidadRecaudadora,
                PagoReferenciaId = model.DatosPago.PagoId,
                MontoDevolucion = model.MontoDevolucion,
                FecAprueba = model.FecAprueba,
                FecDevuelve = model.FecDevuelve,
                FecPagoRef = model.DatosPago.FecPago,
                Comentario = model.Comentario,
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