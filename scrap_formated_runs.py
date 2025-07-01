#!/usr/bin/env python3
"""
GitHub Workflow Runs Extractor - Versión Mejorada
Extrae información de workflow runs de un repositorio de GitHub y parsea logs a nivel de step
"""

from collections import defaultdict
import requests
import json
import os
import sys
import zipfile
import tempfile
import re
import yaml
from datetime import datetime
from typing import Dict, List, Optional, Tuple
import argparse

class GitHubRunsExtractor:
    def __init__(self, token: Optional[str] = None):
        """
        Inicializa el extractor con un token de GitHub (opcional pero recomendado)
        
        Args:
            token: Personal Access Token de GitHub
        """
        self.token = token
        self.headers = {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28'
        }
        
        if self.token:
            self.headers['Authorization'] = f'Bearer {self.token}'
    
    def get_workflow_runs(self, owner: str, repo: str, per_page: int = 100, page: int = 1) -> Dict:
        """
        Obtiene los workflow runs de un repositorio
        
        Args:
            owner: Propietario del repositorio
            repo: Nombre del repositorio
            per_page: Número de resultados por página (máximo 100)
            page: Número de página
            
        Returns:
            Dict con la respuesta de la API
        """
        url = f"https://api.github.com/repos/{owner}/{repo}/actions/runs"
        params = {
            'per_page': per_page,
            'page': page
        }
        
        try:
            response = requests.get(url, headers=self.headers, params=params)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error al obtener runs: {e}")
            return {}
    
    def get_workflow_details(self, owner: str, repo: str, workflow_id: int) -> Dict:
        """
        Obtiene detalles de un workflow específico
        
        Args:
            owner: Propietario del repositorio
            repo: Nombre del repositorio
            workflow_id: ID del workflow
            
        Returns:
            Dict con información del workflow
        """
        url = f"https://api.github.com/repos/{owner}/{repo}/actions/workflows/{workflow_id}"
        
        try:
            response = requests.get(url, headers=self.headers)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error al obtener workflow {workflow_id}: {e}")
            return {}
    
    def get_workflow_content(self, owner: str, repo: str, workflow_path: str, ref: str = "main") -> str:
        """
        Obtiene el contenido del archivo de workflow YAML
        
        Args:
            owner: Propietario del repositorio
            repo: Nombre del repositorio
            workflow_path: Ruta del archivo de workflow
            ref: Rama o commit (por defecto main)
            
        Returns:
            Contenido del archivo YAML como string
        """
        url = f"https://api.github.com/repos/{owner}/{repo}/contents/{workflow_path}"
        params = {'ref': ref}
        
        try:
            response = requests.get(url, headers=self.headers, params=params)
            response.raise_for_status()
            content_data = response.json()
            
            if content_data.get('encoding') == 'base64':
                import base64
                content = base64.b64decode(content_data['content']).decode('utf-8')
                return content
            
            return content_data.get('content', '')
        except requests.exceptions.RequestException as e:
            print(f"Error al obtener contenido del workflow {workflow_path}: {e}")
            return ""
    
    def parse_workflow_yaml(self, yaml_content: str) -> Dict:
        """
        Parsea el contenido YAML del workflow
        
        Args:
            yaml_content: Contenido del archivo YAML
            
        Returns:
            Diccionario con la estructura del workflow parseada
        """
        try:
            return yaml.safe_load(yaml_content)
        except yaml.YAMLError as e:
            print(f"Error al parsear YAML: {e}")
            return {}
    
    def get_job_steps_from_yaml(self, workflow_yaml: Dict, job_name: str) -> List[Dict]:
        """
        Extrae los steps buscando tanto la clave del job como su campo 'name'
        """
        jobs = workflow_yaml.get('jobs', {})
        
        # 1) intento por clave exacta
        if job_name in jobs:
            return jobs[job_name].get('steps', [])
        
        # 2) intento buscando en cada job su campo 'name'
        for job_id, job_data in jobs.items():
            if job_data.get('name') == job_name:
                return job_data.get('steps', [])
        
        # 3) (opcional) fallback a matching parcial
        for job_id, job_data in jobs.items():
            if job_name.lower() in str(job_data.get('name', '')).lower():
                return job_data.get('steps', [])
        
        # no lo encontré
        print(f"[WARN] No hallé YAML job para '{job_name}'. Claves disponibles: {list(jobs.keys())}")
        return []

    def get_step_workflow_code(self, step: Dict) -> str:
        """
        Obtiene el código del step en formato YAML para mostrarlo en los logs
        
        Args:
            step: Diccionario con información del step
            
        Returns:
            String con el código del step formateado
        """
        code_lines = []
        
        if 'run' in step:
            code_lines.append(f"Run:\n{step['run']}")
        if 'uses' in step:
            code_lines.append(f"Uses: {step['uses']}")
        if 'name' in step:
            code_lines.append(f"Name: {step['name']}")
        if 'with' in step:
            code_lines.append("With:")
            for key, value in step['with'].items():
                code_lines.append(f"  {key}: {value}")
        if 'env' in step:
            code_lines.append("Env:")
            for key, value in step['env'].items():
                code_lines.append(f"  {key}: {value}")
        
        return '\n'.join(code_lines)
    
    def get_step_identifier(self, step: Dict) -> str:
        """
        Obtiene el identificador del step para hacer matching con los logs
        
        Args:
            step: Diccionario con información del step
            
        Returns:
            String identificador del step
        """
        if step is None or step == {}:
            print("[DEBUG] Step is None or empty for identifier")
            return "Run Unknown Step"
        if 'run' in step:
            # Si el YAML incluía literalmente el '|' en la cadena,
            # este método lo elimina antes de tomar la primera línea
            raw = step['run']
            print(f"[DEBUG] Raw run content: {raw!r}")
            # Partimos por líneas
            lines = raw.splitlines()
            if lines:
                first = lines[0]
                # Quitamos cualquier '|' inicial y espacios en blanco
                first = first.lstrip('|').strip()
                return f"Run {first}"
            else:
                return "Run Unknown Step"
        elif 'uses' in step:
            return f"Run {step['uses']}"
        elif 'name' in step:
            return f"Run {step['name']}"
        else:
            return "Run Unknown Step"

    
    def parse_log_by_steps(self, log_content: str, job_steps: List[Dict], job_name: str) -> List[Dict]:
        """
        Parsea el log dividiéndolo por steps
        
        Args:
            log_content: Contenido completo del log
            job_steps: Lista de steps del job desde el YAML
            job_name: Nombre del job
            
        Returns:
            Lista de steps con sus respectivos logs
        """
        parsed_steps = []
        # log_lines = log_content.split('\n')
        cleaned = re.sub(r'\x1b\[[0-9;]*[mK]', '', log_content)
        # elimina marcadores ##[group], ##[section]…
        cleaned = re.sub(r'##\[[^\]]+\]', '', cleaned)
        log_lines = cleaned.split('\n')
        print(f"[DEBUG parse] {len(log_lines)} líneas a parsear para job «{job_name}»")
        print(f"[DEBUG parse] Steps a buscar: {len(job_steps)}")
        
        # Identificar el setup job
        setup_log = []
        setup_end_pattern = f"Complete job name: {job_name}"
        setup_end_idx = 0
        
        for i, line in enumerate(log_lines):
            if setup_end_pattern in line:
                setup_end_idx = i
                break
            setup_log.append(line)
        
        # Agregar setup step
        setup_step = {
            'name': 'Set up job',
            'type': 'setup',
            'log_content': '\n'.join(setup_log),
            'start_line': 0,
            'end_line': setup_end_idx
        }
        parsed_steps.append(setup_step)
        
        # Crear patrones de búsqueda para cada step
        step_patterns = []
        for step in job_steps:
            identifier = self.get_step_identifier(step)
            print(f"[DEBUG parse] Pattern a buscar: {identifier!r}")
            step_patterns.append({
                'step': step,
                'pattern': identifier,
                'found': False,
                'start_idx': -1,
                'end_idx': -1
            })
        for p in step_patterns:
            print(f"[DEBUG parse] {p['pattern']!r} found={p['found']} start={p['start_idx']}")
        
        # Buscar cada step en el log
        remaining_lines = log_lines[setup_end_idx + 1:]
        
        for i, line in enumerate(remaining_lines, start=setup_end_idx + 1):
            for pattern_info in step_patterns:
                if not pattern_info['found']:
                    # \b para word boundaries, IGNORECASE para casing flexible
                    pat = re.escape(pattern_info['pattern'])
                    if re.search(rf'\b{pat}\b', line, re.IGNORECASE):
                        pattern_info['found'] = True
                        pattern_info['start_idx'] = i
                        break
        
        # Determinar los rangos de cada step
        found_patterns = [p for p in step_patterns if p['found']]
        found_patterns.sort(key=lambda x: x['start_idx'])
        
        for i, pattern_info in enumerate(found_patterns):
            start_idx = pattern_info['start_idx']
            
            # El final del step es el inicio del siguiente step o el final del log
            if i + 1 < len(found_patterns):
                end_idx = found_patterns[i + 1]['start_idx'] - 1
            else:
                end_idx = len(log_lines) - 1
            
            pattern_info['end_idx'] = end_idx
            
            # Extraer el log del step
            step_log_lines = log_lines[start_idx:end_idx + 1]
            step_log_content = '\n'.join(step_log_lines)
            workflow_code = self.get_step_workflow_code(pattern_info['step'])
            
            step_data = {
                'name': pattern_info['step'].get('name', 'Run ' + pattern_info['step'].get('uses', '')),
                'type': 'action',
                'uses': pattern_info['step'].get('uses'),
                'run': pattern_info['step'].get('run'),
                'with': pattern_info['step'].get('with', {}),
                'env': pattern_info['step'].get('env', {}),
                'log_content': step_log_content,
                'start_line': start_idx,
                'end_line': end_idx,
                'pattern_matched': pattern_info['pattern'],
                'workflow_code': workflow_code or ''
            }
            parsed_steps.append(step_data)
        
        # Agregar steps que no se encontraron en el log
        for pattern_info in step_patterns:
            if not pattern_info['found']:
                workflow_code = self.get_step_workflow_code(pattern_info['step'])
                step_data = {
                    'name': pattern_info['step'].get('name', 'Unnamed Step'),
                    'type': 'action',
                    'uses': pattern_info['step'].get('uses'),
                    'run': pattern_info['step'].get('run'),
                    'with': pattern_info['step'].get('with', {}),
                    'env': pattern_info['step'].get('env', {}),
                    'log_content': '',
                    'start_line': -1,
                    'end_line': -1,
                    'pattern_matched': pattern_info['pattern'],
                    'note': 'Step not found in log',
                    'workflow_code': workflow_code or ''
                }
                parsed_steps.append(step_data)
        
        return parsed_steps
    
    def get_run_jobs(self, owner: str, repo: str, run_id: int) -> List[Dict]:
        """
        Obtiene los jobs de un run específico
        
        Args:
            owner: Propietario del repositorio
            repo: Nombre del repositorio
            run_id: ID del run
            
        Returns:
            Lista de jobs
        """
        url = f"https://api.github.com/repos/{owner}/{repo}/actions/runs/{run_id}/jobs"
        
        try:
            response = requests.get(url, headers=self.headers)
            response.raise_for_status()
            return response.json().get('jobs', [])
        except requests.exceptions.RequestException as e:
            print(f"Error al obtener jobs del run {run_id}: {e}")
            return []
    
    def get_run_logs(self, owner: str, repo: str, run_id: int) -> Dict[str, str]:
        """
        Obtiene los logs de un run específico y los descomprime
        
        Args:
            owner: Propietario del repositorio
            repo: Nombre del repositorio
            run_id: ID del run
            
        Returns:
            Dict con job_name -> log_content
        """
        url = f"https://api.github.com/repos/{owner}/{repo}/actions/runs/{run_id}/logs"
        logs_dict = defaultdict(str)
        os.makedirs('logs', exist_ok=True)
        
        try:
            response = requests.get(url, headers=self.headers)
            response.raise_for_status()
            
            # Crear archivo temporal para el ZIP
            with tempfile.NamedTemporaryFile(delete=False, suffix='.zip') as temp_zip:
                temp_zip.write(response.content)
                temp_zip_path = temp_zip.name
            
            # Extraer logs del ZIP
            with zipfile.ZipFile(temp_zip_path, 'r') as zip_file:
                for file_name in zip_file.namelist():
                    if file_name.endswith('.txt'):
                        if '/' in file_name:  # <<<<< Cambio clave aquí
                            continue
                        with zip_file.open(file_name) as log_file:
                            log_content = log_file.read().decode('utf-8', errors='ignore')
                            
                            # Extraer nombre del job del nombre del archivo
                            job_name = self._extract_job_name_from_filename(file_name)
                            #print(f"Procesando log para job: {job_name}")
                            safe_name = f"{run_id}_" + \
                                job_name.replace(' ', '_').replace('/', '_') + '.txt'
                            out_path = os.path.join('logs', safe_name)

                            # Guardar en disco
                            with open(out_path, 'w', encoding='utf-8') as f:
                                f.write(log_content)
                            logs_dict[job_name] = log_content
                            # print(logs_dict[job_name][:50] + '...')  # Mostrar solo los primeros 100 caracteres
                            
            
            # Limpiar archivo temporal
            os.unlink(temp_zip_path)
            
        except requests.exceptions.RequestException as e:
            print(f"Error al obtener logs del run {run_id}: {e}")
        except Exception as e:
            print(f"Error al procesar logs del run {run_id}: {e}")
        
        return logs_dict
    
    def _extract_job_name_from_filename(self, filename: str) -> str:
        """
        Extrae el nombre del job del nombre del archivo de log
        
        Args:
            filename: Nombre del archivo (ej: "1_build.txt", "2_test-job.txt")
            
        Returns:
            Nombre del job limpio
        """
        # Remover extensión .txt
        name_without_ext = filename.replace('.txt', '')
        
        # Remover prefijo numérico (ej: "1_", "2_", etc.)
        match = re.match(r'^\d+_(.+)', name_without_ext)
        if match:
            return match.group(1)
        
        return name_without_ext
    
    def _match_job_with_log(self, job: Dict, logs_dict: Dict[str, str]) -> str:
        job_name = job.get('name', '')
        # Normalizar nombres para comparación
        normalizer = lambda s: re.sub(r'\W+', '_', s).lower()
        job_name_norm = normalizer(job_name)
        
        # 1. Buscar coincidencia exacta normalizada
        for log_name, log_content in logs_dict.items():
            if job_name_norm == normalizer(log_name):
                return log_content
        
        # 2. Buscar coincidencia parcial
        for log_name, log_content in logs_dict.items():
            log_name_norm = normalizer(log_name)
            if job_name_norm in log_name_norm or log_name_norm in job_name_norm:
                return log_content
        
        return ""
    
    def process_run_data(self, run_data: Dict, workflow_data: Dict, jobs_data: List[Dict], 
                        logs_dict: Dict[str, str] = None, workflow_yaml: Dict = None) -> Dict:
        """
        Procesa y estructura los datos del run según el formato requerido
        
        Args:
            run_data: Datos del run
            workflow_data: Datos del workflow
            jobs_data: Datos de los jobs
            logs_dict: Diccionario con logs por job
            workflow_yaml: Contenido YAML del workflow parseado
            
        Returns:
            Dict con los datos procesados
        """
        # Procesar jobs y agregar logs parseados por steps
        processed_jobs = []
        if jobs_data:
            for job in jobs_data:
                
                processed_job = {
                    'id': job.get('id'),
                    'node_id': job.get('node_id'),
                    'run_attempt': job.get('run_attempt'),
                    'name': job.get('name'),
                    'status': job.get('status'),
                    'conclusion': job.get('conclusion'),
                    'created_at': job.get('created_at'),
                    'started_at': job.get('started_at'),
                    'completed_at': job.get('completed_at'),
                    'url': job.get('url'),
                    'html_url': job.get('html_url'),
                    'runner_name': job.get('runner_name'),
                    'labels': job.get('labels', []),
                    'steps': job.get('steps', [])
                }
                
                # Agregar logs parseados por steps si están disponibles
                if logs_dict and workflow_yaml:
                    log_content = self._match_job_with_log(job, logs_dict)
                    if log_content:
                        job_steps = self.get_job_steps_from_yaml(workflow_yaml, job.get('name', ''))
                        parsed_steps = self.parse_log_by_steps(log_content, job_steps, job.get('name', ''))
                        for step in processed_job['steps']:
                            step['workflow_code'] = next(
                                (ps.get('workflow_code') for ps in parsed_steps if ps.get('name') == step['name']), 
                                self.get_step_workflow_code(step)
                            )
                            
                            step['log_content'] = next((ps['log_content'] for ps in parsed_steps if ps.get('name') == step['name']), None)
                        #processed_job['parsed_steps'] = parsed_steps
                        #processed_job['raw_log'] = log_content
                    else:
                        processed_job['parsed_steps'] = []
                        processed_job['raw_log'] = ""
                else:
                    processed_job['parsed_steps'] = []
                    processed_job['raw_log'] = ""
                
                processed_jobs.append(processed_job)
        
        processed_run = {
            'id': run_data.get('id'),
            'name': run_data.get('name'),
            'display_title': run_data.get('display_title'),
            'node_id': run_data.get('node_id'),
            'run_number': run_data.get('run_number'),
            'event': run_data.get('event'),
            'status': run_data.get('status'),
            'conclusion': run_data.get('conclusion'),
            'workflow_id': run_data.get('workflow_id'),
            'check_suite_id': run_data.get('check_suite_id'),
            'url': run_data.get('url'),
            'html_url': run_data.get('html_url'),
            'created_at': run_data.get('created_at'),
            'updated_at': run_data.get('updated_at'),
            'run_started_at': run_data.get('run_started_at'),
            'run_attempt': run_data.get('run_attempt'),
            'actor': run_data.get('actor', {}),
            'triggering_actor': run_data.get('triggering_actor', {}),
            'head_commit': run_data.get('head_commit', {}),
            'repository': run_data.get('repository', {}),
            'workflow': workflow_data,
            'jobs': processed_jobs
        }
        
        return processed_run
    
    def extract_runs(self, owner: str, repo: str, max_runs: int = None, 
                    include_jobs: bool = True, include_workflow_details: bool = True,
                    include_logs: bool = True, parse_steps: bool = True) -> List[Dict]:
        """
        Extrae todos los runs de un repositorio
        
        Args:
            owner: Propietario del repositorio
            repo: Nombre del repositorio
            max_runs: Número máximo de runs a extraer (None para todos)
            include_jobs: Si incluir información de jobs
            include_workflow_details: Si incluir detalles del workflow
            include_logs: Si incluir logs de los jobs
            parse_steps: Si parsear logs por steps (requiere include_logs=True)
            
        Returns:
            Lista de runs procesados
        """
        all_runs = []
        page = 1
        workflow_cache = {}
        workflow_yaml_cache = {}
        
        print(f"Extrayendo runs del repositorio {owner}/{repo}...")
        
        while True:
            runs_response = self.get_workflow_runs(owner, repo, per_page=100, page=page)
            
            if not runs_response or 'workflow_runs' not in runs_response:
                break
            
            runs = runs_response['workflow_runs']
            
            if not runs:
                break
            
            for run in runs:
                if max_runs and len(all_runs) >= max_runs:
                    break
                
                print(f"Procesando run {run['id']} - {run['name']} ({len(all_runs) + 1})")
                
                # Obtener detalles del workflow si se solicita
                workflow_data = {}
                workflow_yaml = {}
                if include_workflow_details:
                    workflow_id = run['workflow_id']
                    if workflow_id not in workflow_cache:
                        workflow_cache[workflow_id] = self.get_workflow_details(owner, repo, workflow_id)
                    workflow_data = workflow_cache[workflow_id]
                    
                    # Obtener contenido YAML del workflow si se necesita parsear steps
                    if parse_steps and include_logs:
                        workflow_path = workflow_data.get('path', '')
                        if workflow_path and workflow_path not in workflow_yaml_cache:
                            print(f"  Obteniendo contenido YAML del workflow: {workflow_path}")
                            yaml_content = self.get_workflow_content(owner, repo, workflow_path, 
                                                                   run.get('head_sha', 'main'))
                            if yaml_content:
                                workflow_yaml_cache[workflow_path] = self.parse_workflow_yaml(yaml_content)
                        workflow_yaml = workflow_yaml_cache.get(workflow_path, {})
                
                # Obtener jobs si se solicita
                jobs_data = []
                if include_jobs:
                    jobs_data = self.get_run_jobs(owner, repo, run['id'])
                
                # Obtener logs si se solicita
                logs_dict = {}
                if include_logs and include_jobs:
                    print(f"  Descargando logs...")
                    logs_dict = self.get_run_logs(owner, repo, run['id'])
                    for job_name, log_content in logs_dict.items():
                        print(f"    Log para job '{job_name}': {len(log_content)} caracteres")
                    print(f"  Logs obtenidos: {len(logs_dict)} archivos")
                
                # Procesar y agregar el run
                processed_run = self.process_run_data(run, workflow_data, jobs_data, logs_dict, workflow_yaml)
                all_runs.append(processed_run)
            
            if max_runs and len(all_runs) >= max_runs:
                break
            
            page += 1
        
        print(f"Extraídos {len(all_runs)} runs")
        return all_runs
    
    def save_runs_to_file(self, runs: List[Dict], filename: str = None):
        """
        Guarda los runs en un archivo JSON
        
        Args:
            runs: Lista de runs
            filename: Nombre del archivo (opcional)
        """
        if not filename:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"github_runs_{timestamp}.json"
        
        try:
            with open(filename, 'w', encoding='utf-8') as f:
                json.dump(runs, f, indent=2, ensure_ascii=False)
            print(f"Runs guardados en: {filename}")
        except Exception as e:
            print(f"Error al guardar archivo: {e}")
    
    def save_runs_individually(self, runs: List[Dict]):
        """
        Guarda cada run en un archivo JSON individual
        
        Args:
            runs: Lista de runs
            output_dir: Directorio de salida
        """
        try:
            run = runs[0] if runs else {}
            if run['repository']['full_name']:
                repository_name = (run['repository']['full_name']).lower()
                output_dir = repository_name.replace('/', '_')
            else:
                output_dir = os.path.join("unknown_repo")
            os.makedirs(output_dir, exist_ok=True)
            
            for run in runs:
                filename = f"{output_dir}/run_{run['id']}.json"
                with open(filename, 'w', encoding='utf-8') as f:
                    json.dump(run, f, indent=2, ensure_ascii=False)
            
            print(f"Runs guardados individualmente en: {output_dir}/")
        except Exception as e:
            print(f"Error al guardar archivos individuales: {e}")

def main():
    parser = argparse.ArgumentParser(description='Extrae workflow runs de un repositorio de GitHub')
    parser.add_argument('owner', help='Propietario del repositorio')
    parser.add_argument('repo', help='Nombre del repositorio')
    parser.add_argument('--token', help='Token de GitHub (recomendado)', 
                       default=os.getenv('GITHUB_TOKEN'))
    parser.add_argument('--max-runs', type=int, help='Número máximo de runs a extraer')
    parser.add_argument('--output', help='Archivo de salida JSON')
    parser.add_argument('--individual', action='store_true', 
                       help='Guardar cada run en un archivo separado')
    parser.add_argument('--no-logs', action='store_true', 
                       help='No incluir logs de los jobs')
    parser.add_argument('--no-jobs', action='store_true', 
                       help='No incluir información de jobs')
    parser.add_argument('--no-workflow', action='store_true', 
                       help='No incluir detalles del workflow')
    parser.add_argument('--no-step-parsing', action='store_true',
                       help='No parsear logs por steps (usar parsing original por jobs)')
    
    args = parser.parse_args()
    
    # Crear extractor
    extractor = GitHubRunsExtractor(token=args.token)
    
    # Extraer runs
    runs = extractor.extract_runs(
        owner=args.owner,
        repo=args.repo,
        max_runs=args.max_runs,
        include_jobs=not args.no_jobs,
        include_workflow_details=not args.no_workflow,
        include_logs=not args.no_logs and not args.no_jobs,
        parse_steps=not args.no_step_parsing and not args.no_logs and not args.no_jobs
    )
    
    if not runs:
        print("No se encontraron runs")
        return
    
    # Guardar resultados
    if args.individual:
        extractor.save_runs_individually(runs)
    else:
        extractor.save_runs_to_file(runs, args.output)

if __name__ == "__main__":
    main()