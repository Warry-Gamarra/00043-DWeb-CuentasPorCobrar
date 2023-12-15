using Domain.Entities;
using Domain.Helpers;
using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public class TipoComprobanteServiceFacade : ITipoComprobanteServiceFacade
    {
        private ITipoComprobanteService _service;

        public TipoComprobanteServiceFacade()
        {
            _service = new TipoComprobanteService();
        }

        public IEnumerable<SelectViewModel> ListarTiposComprobante(bool soloHabilitados)
        {
            var lista = _service.ListarTiposComprobante(soloHabilitados);

            var result = lista
                .OrderBy(x => x.tipoComprobanteDesc)
                .Select(x => new SelectViewModel() { 
                    Value = x.tipoComprobanteID.ToString(),
                    TextDisplay = x.tipoComprobanteDesc
                });

            return result;
        }

        public IEnumerable<TipoComprobanteModel> ListarTiposComprobante()
        {
            var lista = _service.ListarTiposComprobante(false);

            var result = lista
                .Select(x => new TipoComprobanteModel()
                {
                    tipoComprobanteID = x.tipoComprobanteID,
                    tipoComprobanteCod = x.tipoComprobanteCod,
                    tipoComprobanteDesc = x.tipoComprobanteDesc,
                    inicial = x.inicial,
                    estaHabilitado = x.estaHabilitado
                });

            return result;
        }

        public Response GrabarTipoComprobante(TipoComprobanteModel model, int userID)
        {
            Response response;
            SaveOption saveOption;

            try
            {
                saveOption = model.tipoComprobanteID.HasValue ? SaveOption.Update : SaveOption.Insert;

                var entity = new TipoComprobanteEntity()
                {
                    tipoComprobanteID = model.tipoComprobanteID,
                    tipoComprobanteCod = model.tipoComprobanteCod,
                    tipoComprobanteDesc = model.tipoComprobanteDesc,
                    inicial = model.inicial
                };

                response = _service.GrabarTipoComprobante(entity, saveOption, userID);
            }
            catch (Exception ex)
            {
                response = new Response()
                {
                    Message = ex.Message
                };
            }

            return response;
        }

        public Response ActualizarEstadoTipoComprobante(int tipoComprobanteID, bool estaHabilitado, int userID)
        {
            Response response;
            try
            {
                response = _service.ActualizarEstadoTipoComprobante(tipoComprobanteID, estaHabilitado, userID);
            }
            catch (Exception ex)
            {
                response = new Response()
                {
                    Message = ex.Message
                };
            }

            return response;
        }

        public Response EliminarEstadoTipoComprobante(int tipoComprobanteID)
        {
            Response response;
            try
            {
                response = _service.EliminarEstadoTipoComprobante(tipoComprobanteID);
            }
            catch (Exception ex)
            {
                response = new Response()
                {
                    Message = ex.Message
                };
            }

            return response;
        }
    }
}