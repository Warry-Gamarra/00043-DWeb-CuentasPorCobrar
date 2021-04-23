﻿using Domain.Entities;
using Domain.Helpers;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models
{
    public class EstructuraArchivoModel
    {
        private readonly IArchivoIntercambio _archivoIntercambio;
        private readonly ICampoTablaPago _campoTablaPago;

        public EstructuraArchivoModel()
        {
            _archivoIntercambio = new ArchivoIntercambio();
            _campoTablaPago = new CampoTablaPago();
        }


        public List<ArchivoIntercambioViewModel> ObtenerArchivoIntercambio()
        {
            List<ArchivoIntercambioViewModel> result = new List<ArchivoIntercambioViewModel>();
            var secciones = _archivoIntercambio.FindSeccionesArchivos();
            var columnas = _archivoIntercambio.FindColumnasSeccion();

            foreach (var item in _archivoIntercambio.Find())
            {
                result.Add(new ArchivoIntercambioViewModel(item)
                {
                    CantSecciones = secciones.Count(x => x.TipArchivoEntFinanID == item.TipArchivoEntFinanID),
                    CantColumns = columnas.Count(x => x.TipArchivoEntFinanID == item.TipArchivoEntFinanID)
                });
            }

            return result;
        }

        public RegistrarArchivoIntercambioViewModel ObtenerArchivoIntercambio(int archivoIntercambioID)
        {
            RegistrarArchivoIntercambioViewModel result = new RegistrarArchivoIntercambioViewModel();
            var data = _archivoIntercambio.Find(archivoIntercambioID);
            var tiposArchivo = Enum.GetValues(typeof(TipoArchivoEntFinan)).Cast<TipoArchivoEntFinan>();

            result = new RegistrarArchivoIntercambioViewModel()
            {
                EstructArchivoID = data.TipArchivoEntFinanID.Value,
                TipoArchivo = tiposArchivo.FirstOrDefault(x => (int)x == data.TipoArchivoID),
                EntiFinanId = data.EntidadFinanID
            };

            return result;
        }

        public List<ArchivoIntercambioViewModel> ObtenerArchivoIntercambioEntidadFinanciera(int entidadFinancieraId)
        {
            List<ArchivoIntercambioViewModel> result = new List<ArchivoIntercambioViewModel>();
            var secciones = _archivoIntercambio.FindSeccionesArchivos();
            var columnas = _archivoIntercambio.FindColumnasSeccion();

            foreach (var item in _archivoIntercambio.Find().Where(x => x.EntidadFinanID == entidadFinancieraId))
            {
                result.Add(new ArchivoIntercambioViewModel(item)
                {
                    CantSecciones = secciones.Count(x => x.TipArchivoEntFinanID == item.TipArchivoEntFinanID),
                    CantColumns = columnas.Count(x => x.TipArchivoEntFinanID == item.TipArchivoEntFinanID)
                });
            }

            return result;
        }

        public Response ChangeState(int archivoIntercambioID, bool currentState, int currentUserId, string returnUrl)
        {
            Response result = _archivoIntercambio.ChangeState(archivoIntercambioID, currentState, currentUserId);

            result.Redirect = returnUrl;

            return result;
        }


        public Response Save(RegistrarArchivoIntercambioViewModel model, int currentUserId)
        {
            ArchivoIntercambio archivoIntercambio = new ArchivoIntercambio()
            {
                TipArchivoEntFinanID = model.EstructArchivoID,
                EntidadFinanID = model.EntiFinanId,
                TipoArchivoID = (int)model.TipoArchivo
            };

            Response result = _archivoIntercambio.Save(archivoIntercambio, currentUserId, model.EstructArchivoID == 0
                                                                                        ? SaveOption.Insert : SaveOption.Update);

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



        public List<SelectViewModel> ObtenerTiposArchivo()
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            foreach (var item in Enum.GetValues(typeof(TipoArchivoEntFinan)).Cast<TipoArchivoEntFinan>())
            {
                result.Add(new SelectViewModel()
                {
                    Value = item.ToString(),
                    TextDisplay = item.ToString().Replace('_', ' ').ToUpper()
                });
            }

            return result;
        }

        public List<SelectViewModel> ObtenerColumnasTabla(string nombreTabla)
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            foreach (var item in _campoTablaPago.GetBDColumns(nombreTabla))
            {
                result.Add(new SelectViewModel()
                {
                    Value = item.ToString(),
                    TextDisplay = item.ToString()
                });
            }

            return result;
        }

        public List<SelectViewModel> ObtenerTablasBD()
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            foreach (var item in _campoTablaPago.GetBDTables())
            {
                result.Add(new SelectViewModel()
                {
                    Value = item.ToString(),
                    TextDisplay = item.ToString()
                });
            }

            return result;
        }

        public List<CamposTablaViewModel> ObtenerCamposTabla(TipoArchivoEntFinan? tipoArchivoEnt)
        {
            List<CamposTablaViewModel> result = new List<CamposTablaViewModel>();
            var data = new List<CampoTablaPago>();
            if (tipoArchivoEnt.HasValue)
            {
                data = _campoTablaPago.Find().Where(x => x.TipoArchivo == (int)tipoArchivoEnt).ToList();
            }
            else
            {
                data = _campoTablaPago.Find();
            }

            foreach (var item in data)
            {
                result.Add(new CamposTablaViewModel(item));
            }

            return result;
        }


        public CamposTablaViewModel ObtenerCampoTabla(int campoTablaId)
        {
            var data = _campoTablaPago.Find(campoTablaId);

            return new CamposTablaViewModel(data);
        }

        public Response GrabarCampoTabla(CamposTablaViewModel model, int currentUserId)
        {
            CampoTablaPago campoTablaPago = new CampoTablaPago()
            {
                CampoId = model.CampoId.HasValue ? model.CampoId.Value : 0,
                NombreCampoTabla = model.NombreCampoTabla,
                NombreTabla = model.NombreTabla,
                DescCampo = model.DescCampo,
                TipoArchivo = (int)model.TipoArchivo,

            };

            Response result = _campoTablaPago.Save(campoTablaPago, currentUserId, (campoTablaPago.CampoId == 0 ? SaveOption.Insert : SaveOption.Update));

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

        public Response CampoChangeState(int campoTablaPagoId, bool currentState, int currentUserId, string returnUrl)
        {
            Response result = _campoTablaPago.ChangeState(campoTablaPagoId, currentState, currentUserId);

            result.Redirect = returnUrl;

            return result;
        }



        public Response GrabarSeccionesArchivo(List<SeccionArchivoViewModel> lstSeccionArchivoViewModel, int currentUserId)
        {
            Response result = new Response() { Value = true };

            foreach (var seccionArchivoViewModel in lstSeccionArchivoViewModel)
            {
                var seccionArchivo = new SeccionArchivo()
                {
                    TipArchivoEntFinanID = seccionArchivoViewModel.EstructArchivoID,
                    SecArchivoID = seccionArchivoViewModel.SecArchivoID,
                    SecArchivoDesc = seccionArchivoViewModel.SecArchivoDesc,
                    FilaInicio = seccionArchivoViewModel.FilPosicionIni,
                    FilaFin = seccionArchivoViewModel.FilPosicionFin,
                };


                var lstColumnasSeccion = new List<ColumnaSeccion>();
                foreach (var columna in seccionArchivoViewModel.ColumnasSeccion)
                {
                    lstColumnasSeccion.Add(new ColumnaSeccion()
                    {
                        SecArchivoID = columna.SeccionArchivo,
                        ColSecID = columna.ColumnSecID,
                        ColSecDesc = columna.ColSecDesc,
                        ColumnaInicio = columna.ColPosicionIni,
                        ColumnaFin = columna.ColPosicionFin,
                        CampoPagoID = columna.CampoTablaId,
                    });
                };

                var loopResult = _archivoIntercambio.EstructuraSeccionSave(seccionArchivo, lstColumnasSeccion, currentUserId,
                    (seccionArchivoViewModel.EstructArchivoID == 0 ? SaveOption.Insert : SaveOption.Update));

                result.Value = result.Value && loopResult.Value;
                if (result.Value)
                {
                    result.Message = loopResult.Message;
                }
                else
                {
                    result.Message += "- " + loopResult.Message + "\n";
                }

            }

            if (result.Value)
            {
                if (string.IsNullOrEmpty(result.Action))
                {
                    result.Success(false);
                }
                else
                {
                    result.Warning(false);
                }
            }
            else
            {
                result.Error(true);
            }
            return result;
        }


        public List<SeccionArchivoViewModel> ObtenerEstructuraArchivo(int entidadFinancieraId, TipoArchivoEntFinan tipoArchivoEntFinan)
        {
            List<SeccionArchivoViewModel> result = new List<SeccionArchivoViewModel>();
            var archivoIntercambio = _archivoIntercambio.Find()
                                                        .FirstOrDefault(x => x.Habilitado &&
                                                                             x.EntidadFinanID == entidadFinancieraId &&
                                                                             x.TipoArchivoID == (int)tipoArchivoEntFinan);
            if (archivoIntercambio != null)
            {
                List<SeccionArchivo> secciones = _archivoIntercambio.FindSeccionesArchivos(archivoIntercambio.TipArchivoEntFinanID.Value);

                foreach (var seccion in secciones)
                {
                    result.Add(new SeccionArchivoViewModel()
                    {
                        EstructArchivoID = seccion.TipArchivoEntFinanID,
                        SecArchivoID = seccion.SecArchivoID,
                        FilPosicionIni = seccion.FilaInicio,
                        FilPosicionFin = seccion.FilaFin,
                        ColumnasSeccion = _archivoIntercambio.FindColumnasSeccion(seccion.SecArchivoID)
                                                             .Select(x => new ColumnaSeccionViewModel
                                                             {
                                                                 ColumnSecID = x.ColSecID,
                                                                 ColPosicionIni = x.ColumnaInicio,
                                                                 ColPosicionFin = x.ColumnaFin,
                                                                 CampoTablaId = x.CampoPagoID,
                                                                 CampoTablaNom = x.CampoPagoNom,
                                                                 TablaCampoNom = x.TablaPagoNom
                                                             })
                                                             .ToList()
                    });
                }
            }


            return result;
        }
    }
}